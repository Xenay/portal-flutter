// lib/views/models_view.dart
import 'package:ai_help/services/model_service.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart'; // Keep using if needed elsewhere

// Import services and models (adjust paths)
import '../services/api_service.dart';
import '../models/model_info.dart';
import '../widgets/sidebar.dart'; // Import sidebar

class ModelsView extends StatefulWidget {
  const ModelsView({Key? key}) : super(key: key);

  @override
  _ModelsViewState createState() => _ModelsViewState();
}

class _ModelsViewState extends State<ModelsView> {
  // Use the specific type now
  late Future<List<ModelInfo>> _modelsFuture;
  // Track loading state for individual actions
  final Map<String, bool> _isLoadingAction = {}; // Key: modelId, Value: isLoading

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() {
      _modelsFuture = ModelService.fetchModels();
    });
  }

  // Helper to show feedback, potentially updating UI state
  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return; // Check if the widget is still in the tree
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  // --- Action Handlers ---
  Future<void> _handleInstall(String modelId) async {
    setState(() => _isLoadingAction[modelId] = true);
    try {
      final msg = await ModelService.installModel(modelId);
      _showFeedback(msg);
      await _loadModels(); // Refresh list after action
    } catch (e) {
      _showFeedback(e.toString(), isError: true);
    } finally {
      // Check if mounted before calling setState
      if (mounted) {
         setState(() => _isLoadingAction[modelId] = false);
      }
    }
  }

  Future<void> _handleActivate(String modelId) async {
     setState(() => _isLoadingAction[modelId] = true);
    try {
      final msg = await ModelService.activateModel(modelId);
      _showFeedback(msg);
      await _loadModels();
    } catch (e) {
      _showFeedback(e.toString(), isError: true);
    } finally {
       if (mounted) {
        setState(() => _isLoadingAction[modelId] = false);
       }
    }
  }

   Future<void> _handleDelete(String modelId) async {
     // Optional: Show confirmation dialog
     final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete model "$modelId"? This action cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
      );

     if (confirmed != true) return; // User cancelled

     setState(() => _isLoadingAction[modelId] = true);
     try {
       final msg = await ModelService.deleteModel(modelId);
       _showFeedback(msg);
       await _loadModels();
     } catch (e) {
       _showFeedback(e.toString(), isError: true);
     } finally {
        if (mounted) {
          setState(() => _isLoadingAction[modelId] = false);
        }
     }
   }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Match UserView background
      body: Row( // Use Row instead of HStack for standard Flutter
        children: [
          const Sidebar(), // Include the Sidebar
          Expanded(
            child: RefreshIndicator( // Add pull-to-refresh
              onRefresh: _loadModels,
              color: colorScheme.primary,
              backgroundColor: const Color(0xFF1A1A1A),
              child: FutureBuilder<List<ModelInfo>>(
                future: _modelsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget('Error loading models: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildErrorWidget('No models found in configuration.');
                  }

                  // Data loaded successfully
                  final models = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16), // Adjust padding for potential AppBar/back button space
                    itemCount: models.length,
                    itemBuilder: (context, index) {
                      final model = models[index];
                      // Pass loading state for this specific model's actions
                      final bool isLoading = _isLoadingAction[model.id] ?? false;
                      return _buildModelCard(theme, colorScheme, model, isLoading);
                    },
                  );
                },
              ),
            ),
          ),
          // Consider adding AppBar or keeping the Positioned back button if needed
          // If using AppBar: Add it to Scaffold, remove Positioned button
        ],
      ),
      // Optional: Add a floating action button for adding new models?
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () { /* Navigate to add model view or show dialog */ },
      //   child: Icon(Icons.add),
      // ),
    );
  }

  // --- Helper Widgets ---

  // Build error display widget
  Widget _buildErrorWidget(String message) {
     return Center(
       child: Padding(
         padding: const EdgeInsets.all(20.0),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
             const SizedBox(height: 10),
             Text(
               message,
               textAlign: TextAlign.center,
               style: const TextStyle(color: Colors.white70),
             ),
             const SizedBox(height: 20),
             ElevatedButton.icon(
               icon: const Icon(Icons.refresh),
               label: const Text('Retry'),
               onPressed: _loadModels, // Use the specific load function
             ),
           ],
         ),
       ),
     );
  }


  // Build a Card for a single model - Inspired by UserView Card style
  Widget _buildModelCard(ThemeData theme, ColorScheme colorScheme, ModelInfo model, bool isLoading) {
    return Card(
      color: const Color(0xFF1C1C1C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16), // Spacing between cards
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model Name and Active Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    model.name, // Use the user-friendly name
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (model.active)
                  Chip(
                    label: const Text('Active'),
                    backgroundColor: Colors.greenAccent.withOpacity(0.3),
                    labelStyle: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    visualDensity: VisualDensity.compact,
                     side: BorderSide.none,
                  ),
              ],
            ),
            const SizedBox(height: 4),
             // Model ID or Description
            Text(
              model.description ?? model.id, // Show description or fall back to ID
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Divider(color: Colors.white24, height: 25),

            // Status Row (Installed)
            Row(
              children: [
                 Icon(
                   model.installed ? Icons.check_circle : Icons.cancel_outlined,
                   color: model.installed ? Colors.greenAccent : Colors.grey,
                   size: 18,
                 ),
                 const SizedBox(width: 8),
                 Text(
                    model.installed ? 'Installed' : 'Not Installed',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                 ),
                 // Add more status info if needed (e.g., file size)
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons Row
            // Show appropriate buttons based on state
            // Handle isLoading state for specific actions
            if (isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              ))
            else // Only show buttons if not loading this model's action
               Row(
                 mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
                 children: _buildActionButtons(theme, colorScheme, model),
               )
          ],
        ),
      ),
    );
  }


  // Helper to generate action buttons based on model state
  List<Widget> _buildActionButtons(ThemeData theme, ColorScheme colorScheme, ModelInfo model) {
     final List<Widget> buttons = [];
     final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Smaller padding
          textStyle: theme.textTheme.labelMedium, // Smaller text
          visualDensity: VisualDensity.compact,
     );
     final ButtonStyle deleteButtonStyle = OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Smaller padding
        textStyle: theme.textTheme.labelMedium, // Smaller text
        visualDensity: VisualDensity.compact,
        foregroundColor: Colors.redAccent,
         side: const BorderSide(color: Colors.redAccent),
     );


     if (!model.installed) {
       buttons.add(
          ElevatedButton.icon(
             icon: const Icon(Icons.download, size: 16),
             label: const Text('Install'),
             style: buttonStyle.copyWith(backgroundColor: MaterialStateProperty.all(colorScheme.primary)),
             onPressed: () => _handleInstall(model.id),
           )
       );
     } else { // Is installed
         if (!model.active) {
           buttons.add(
             ElevatedButton.icon(
               icon: const Icon(Icons.play_circle_filled, size: 16),
               label: const Text('Activate'),
               style: buttonStyle.copyWith(backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent)),
               onPressed: () => _handleActivate(model.id),
             ),
           );
           buttons.add(const SizedBox(width: 8)); // Spacing between buttons
           buttons.add(
             OutlinedButton.icon( // Use OutlinedButton for delete
               icon: const Icon(Icons.delete_outline, size: 16),
               label: const Text('Delete'),
               style: deleteButtonStyle,
               onPressed: () => _handleDelete(model.id),
             ),
           );
         } else { // Is installed AND active
            // Optionally show a 'Deactivate' button or just indicate it's active
           buttons.add(
              Text('Active', style: TextStyle(color: Colors.greenAccent, fontStyle: FontStyle.italic))
           );
         }
     }
     return buttons;
   }
}