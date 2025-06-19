// lib/views/options_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:intl/intl.dart'; // For number formatting

// Import services and models
import '../services/options_service.dart';
import '../services/model_service.dart'; // To get the list of models
import '../models/model_info.dart';     // Model definition
import '../widgets/sidebar.dart';       // Sidebar

class OptionsView extends StatefulWidget {
  const OptionsView({Key? key}) : super(key: key);

  @override
  _OptionsViewState createState() => _OptionsViewState();
}

class _OptionsViewState extends State<OptionsView> {
  // State variables
  List<ModelInfo> _models = []; // List of available models
  Map<String, Map<String, dynamic>> _allOptions = {}; // All fetched options
  Map<String, dynamic> _currentEditedOptions = {}; // Local edits for the selected model
  String? _selectedModelId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // For formatting slider labels
  final NumberFormat _numberFormat = NumberFormat("0.0#");

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Fetch models and options concurrently
      final results = await Future.wait([
        ModelService.fetchModels(),
        OptionsService.fetchAllOptions(),
      ]);

      final models = results[0] as List<ModelInfo>;
      final options = results[1] as Map<String, Map<String, dynamic>>;

       // Find the active model to select it initially, or default to first
      final activeModel = models.firstWhere((m) => m.active, orElse: () => models.isNotEmpty ? models.first : ModelInfo(id: '', name: '', installed: false, active: false, repoUrl: '')); // Provide a dummy if no models


      setState(() {
        _models = models;
        _allOptions = options;
        _selectedModelId = models.isNotEmpty ? activeModel.id : null;
         if (_selectedModelId != null) {
           // Initialize edits with fetched data for the selected model
           _currentEditedOptions = Map<String, dynamic>.from(
               _allOptions[_selectedModelId] ?? {});
         } else {
            _currentEditedOptions = {}; // No model selected or available
         }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Error loading data: $e";
        _isLoading = false;
      });
      _showFeedback(_error!, isError: true);
    }
  }

  void _onModelSelected(String? modelId) {
    if (modelId == null || modelId == _selectedModelId) return;
    setState(() {
      _selectedModelId = modelId;
      // Reset edits to the fetched options for the newly selected model
      _currentEditedOptions =
          Map<String, dynamic>.from(_allOptions[modelId] ?? {});
    });
  }

  void _updateOptionValue(String key, dynamic value) {
    setState(() {
      _currentEditedOptions[key] = value;
    });
  }

  void _resetChanges() {
     if (_selectedModelId == null) return;
     setState(() {
        // Revert local edits to the originally fetched values for this model
        _currentEditedOptions = Map<String, dynamic>.from(_allOptions[_selectedModelId!] ?? {});
        // Optional: could re-trigger _loadInitialData, but reverting local state is faster
     });
     _showFeedback("Changes reset to last saved state.");
  }

  Future<void> _saveChanges() async {
     if (_selectedModelId == null || _isSaving) return;

     setState(() => _isSaving = true);
     try {
        final updatedParams = await OptionsService.updateOptions(
           _selectedModelId!, _currentEditedOptions);

        // Update the main options map with the saved data
        setState(() {
           _allOptions[_selectedModelId!] = updatedParams;
           // Keep _currentEditedOptions aligned with the saved state
           _currentEditedOptions = Map<String, dynamic>.from(updatedParams);
        });
        _showFeedback("Options saved successfully!");

     } catch (e) {
        _showFeedback("Error saving options: $e", isError: true);
     } finally {
         if (mounted) {
            setState(() => _isSaving = false);
         }
     }
  }


  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
         behavior: SnackBarBehavior.floating, // More modern look
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
         margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Dark background
      body: Row(
        children: [
          const Sidebar(), // Your navigation sidebar
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                : _error != null
                    ? _buildErrorWidget(_error!) // Display error if loading failed
                    : _buildOptionsContent(theme, colorScheme),
          ),
        ],
      ),
    );
  }


   Widget _buildErrorWidget(String message) {
     return Center(
       child: Padding(
         padding: const EdgeInsets.all(20.0),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.error_outline, color: Colors.redAccent.shade100, size: 40),
             const SizedBox(height: 15),
             Text(
               message,
               textAlign: TextAlign.center,
               style: const TextStyle(color: Colors.white70, fontSize: 16),
             ),
             const SizedBox(height: 25),
             ElevatedButton.icon(
               icon: const Icon(Icons.refresh),
               label: const Text('Retry'),
               onPressed: _loadInitialData,
               style: ElevatedButton.styleFrom(
                   foregroundColor: Colors.black87, // Text color
                   backgroundColor: const Color(0xFF1A1A1A)// Background color
                   ),
             ),
           ],
         ),
       ),
     );
   }

  Widget _buildOptionsContent(ThemeData theme, ColorScheme colorScheme) {
    // Ensure _models is not empty and _selectedModelId is valid before proceeding
     if (_models.isEmpty || _selectedModelId == null || !_allOptions.containsKey(_selectedModelId)) {
       return _buildErrorWidget("No models available or selected."); // Or a more specific message
     }

     // Get the name of the selected model for the dropdown hint
     final selectedModelName = _models.firstWhere((m) => m.id == _selectedModelId, orElse: () => _models.first).name;


    return Padding(
      padding: const EdgeInsets.only(top: 40.0, left: 24, right: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Model Selector Dropdown ---
          Text("Configure Model:", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
             decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.white24, width: 0.5)
             ),
             child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                   value: _selectedModelId,
                   isExpanded: true,
                   dropdownColor: const Color(0xFF2A2A2A), // Darker dropdown
                   icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                   style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                   hint: Text(selectedModelName, style: const TextStyle(color: Colors.white)), // Show selected model name
                   items: _models.map((ModelInfo model) {
                      return DropdownMenuItem<String>(
                         value: model.id,
                         child: Text(model.name), // Display user-friendly name
                      );
                   }).toList(),
                   onChanged: _onModelSelected,
                ),
             ),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.white24, thickness: 0.5),
          const SizedBox(height: 20),

          // --- Parameters List ---
           Text("Generation Parameters:", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 15),
          Expanded(
            child: ListView( // Use ListView for scrollability if many params
              children: _buildParameterWidgets(theme, colorScheme),
            ),
          ),

          // --- Action Buttons ---
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isSaving ? null : _resetChanges,
                style: OutlinedButton.styleFrom(
                   foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Reset'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                   backgroundColor: colorScheme.primary,
                   foregroundColor: Colors.black87,
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: _isSaving
                    ? const SizedBox(
                       width: 20,
                       height: 20,
                       child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black54))
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParameterWidgets(ThemeData theme, ColorScheme colorScheme) {
    if (_selectedModelId == null) return [const Text("Select a model", style: TextStyle(color: Colors.white))];

    final params = _currentEditedOptions;
    final List<Widget> widgets = [];

    // Define known parameters and their preferred widget types/ranges
    final Map<String, Map<String, dynamic>> paramConfig = {
       'temperature': {'type': 'slider', 'min': 0.0, 'max': 2.0, 'divisions': 200, 'label': 'Temperature', 'description': 'Controls randomness. Lower values are more focused.'},
       'top_p': {'type': 'slider', 'min': 0.0, 'max': 1.0, 'divisions': 100, 'label': 'Top P', 'description': 'Nucleus sampling. Considers tokens with cumulative probability mass.'},
       'repetition_penalty': {'type': 'slider', 'min': 1.0, 'max': 3.0, 'divisions': 200, 'label': 'Repetition Penalty', 'description': 'Penalizes repeating tokens. >1 encourages new words.'},
       'length_penalty': {'type': 'slider', 'min': 0.1, 'max': 5.0, 'divisions': 490, 'label': 'Length Penalty', 'description': 'Penalizes shorter/longer sequences. <1 favors short, >1 favors long.'},
      // Add other known params like max_new_tokens as 'textfield' if needed
      // 'max_new_tokens': {'type': 'textfield', 'label': 'Max New Tokens', 'description': 'Maximum number of tokens to generate.'}
    };

     // Iterate through parameters present in the selected model's config
     params.forEach((key, value) {
        final config = paramConfig[key];
        final label = config?['label'] ?? key; // Use key as fallback label
        final description = config?['description'] ?? ''; // Optional description

        Widget inputWidget;

        if (config != null && config['type'] == 'slider') {
          // Ensure value is double for slider
           double currentValue = 0.0;
           if (value is num) {
             currentValue = value.toDouble();
           } else if (value is String) {
             currentValue = double.tryParse(value) ?? config['min']; // Fallback to min on parse error
           } else {
               currentValue = config['min']; // Fallback if type is unexpected
           }
           // Clamp value within min/max
            currentValue = (currentValue as num).clamp(config['min'], config['max']).toDouble();


           inputWidget = _buildSliderParam(
             theme: theme,
             colorScheme: colorScheme,
             label: label,
             description: description,
             keyName: key,
             value: currentValue,
             min: config['min'],
             max: config['max'],
             divisions: config['divisions'],
           );
        } else if (config != null && config['type'] == 'textfield') {
          // Example for a text field (like max_tokens)
           inputWidget = _buildTextFieldParam(
             theme: theme,
             colorScheme: colorScheme,
             label: label,
             description: description,
             keyName: key,
             value: value, // Keep original type for text field controller
             isNumeric: true, // Example flag for numeric keyboard/formatter
           );
        } else {
           // Default for unknown or non-configured params: Show as Text (read-only for now)
           // Or potentially a generic TextField if editing is desired for all
           inputWidget = _buildReadOnlyParam(
               theme: theme,
               label: label,
               value: value?.toString() ?? 'N/A' // Display value as string
           );
        }

        widgets.add(inputWidget);
        widgets.add(const SizedBox(height: 18)); // Spacing between params
     });

    // Add a message if no parameters were found for the selected model
    if (widgets.isEmpty) {
       widgets.add(Text("No generation parameters found for this model.", style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)));
    }

    return widgets;
  }

  // --- Parameter Widget Builders ---

  Widget _buildSliderParam({
     required ThemeData theme,
     required ColorScheme colorScheme,
     required String label,
     required String description,
     required String keyName,
     required double value,
     required double min,
     required double max,
     required int divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text(label, style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
             Text(_numberFormat.format(value), style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
           ],
        ),
        if (description.isNotEmpty) ...[
           const SizedBox(height: 4),
           Text(description, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60)),
        ],
        const SizedBox(height: 8),
        SliderTheme( // Customize slider appearance
           data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: Colors.grey.shade700,
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withOpacity(0.2),
              trackHeight: 2.0,
              valueIndicatorColor: Colors.grey.shade800,
              valueIndicatorTextStyle: TextStyle(color: Colors.white),
           ),
           child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: _numberFormat.format(value), // Show value on hover/drag
              onChanged: (newValue) {
                 _updateOptionValue(keyName, newValue);
              },
           ),
        ),
      ],
    );
  }

   Widget _buildTextFieldParam({
      required ThemeData theme,
      required ColorScheme colorScheme,
      required String label,
      required String description,
      required String keyName,
      required dynamic value,
      bool isNumeric = false,
   }) {
     final controller = TextEditingController(text: value?.toString() ?? '');
     // Move cursor to end after initial build
     WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
     });

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(label, style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
          if (description.isNotEmpty) ...[
           const SizedBox(height: 4),
           Text(description, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60)),
         ],
         const SizedBox(height: 8),
         TextField(
           controller: controller,
           style: const TextStyle(color: Colors.white),
           keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
           inputFormatters: isNumeric ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null, // Allow numbers and dot
           decoration: InputDecoration(
             filled: true,
             fillColor: const Color(0xFF1C1C1C),
             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8.0),
               borderSide: BorderSide(color: Colors.white24, width: 0.5),
             ),
             enabledBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8.0),
               borderSide: BorderSide(color: Colors.white24, width: 0.5),
             ),
             focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8.0),
               borderSide: BorderSide(color: colorScheme.primary, width: 1.0),
             ),
              hintStyle: TextStyle(color: Colors.white38),
           ),
           onChanged: (newValue) {
             // Try to parse back to number if numeric, otherwise keep as string
              if (isNumeric) {
                 final num? parsedValue = num.tryParse(newValue);
                 if (parsedValue != null) {
                   _updateOptionValue(keyName, parsedValue);
                 } else {
                    // Handle invalid input? Maybe keep string or revert?
                    // For simplicity, we might just let the backend validate
                    _updateOptionValue(keyName, newValue); // Send string if parsing fails
                 }
              } else {
                 _updateOptionValue(keyName, newValue);
              }
           },
         ),
       ],
     );
   }

    Widget _buildReadOnlyParam({
       required ThemeData theme,
       required String label,
       required String value,
    }) {
       return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(label, style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70, fontWeight: FontWeight.w500)),
             Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ],
       );
    }
}