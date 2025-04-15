import 'dart:async'; // Required for StreamSubscription
import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Your ApiService import
import '../widgets/custom_logo.dart'; // Assuming these exist
import '../widgets/sidebar.dart'; // Assuming these exist

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _promptController = TextEditingController();
  String _generatedText = '';
  bool _isLoading = false;
  StreamSubscription? _streamSubscription; // Holds the active stream subscription

  @override
  void dispose() {
    _promptController.dispose();
    _streamSubscription?.cancel(); // Cancel stream when the widget is disposed
    super.dispose();
  }

  // Modify this function to handle streaming
  // In class _ChatViewState:
  Future<void> _handleGeneration() async {
    // --- DEFINE prompt HERE ---
    final prompt = _promptController.text; // Make sure this line exists and is correct

    if (prompt.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    // Cancel any potentially ongoing stream from a previous request
    print('[ChatView] Cancelling previous subscription if any at ${DateTime.now()}');
    await _streamSubscription?.cancel();
    _streamSubscription = null;

    setState(() {
      _isLoading = true;
      _generatedText = ''; // Clear previous output/error
    });
    print('[ChatView] Set loading state, cleared text at ${DateTime.now()}');

    try {
      print('[ChatView] Calling ApiService.generateTextStream with prompt: "${prompt.substring(0, prompt.length > 20 ? 20 : prompt.length)}..." at ${DateTime.now()}'); // Log using the variable
      // --- USE prompt HERE ---
      final stream = ApiService.generateTextStream(
        prompt, // Use the 'prompt' variable defined above
        maxNewTokens: 5000,
      );

      print('[ChatView] Subscribing to stream at ${DateTime.now()}');
      // ... rest of the stream listening logic (onData, onError, onDone) ...
       _streamSubscription = stream.listen(
        (chunk) {
          print('[ChatView] onData received (${chunk.length} chars) at ${DateTime.now()}');
          if (mounted) {
            setState(() { _generatedText += chunk; });
          }
        },
        onError: (error) {
          print('[ChatView] onError: $error at ${DateTime.now()}');
          if (mounted) { // Check if widget is still mounted before calling setState
             setState(() {
               _generatedText += "\n\n[Stream Error]: $error";
               _isLoading = false;
             });
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Error during generation: $error'), backgroundColor: Colors.red),
             );
          }
        },
        onDone: () {
          print('[ChatView] onDone received at ${DateTime.now()}');
           if (mounted) {
              setState(() {
                _isLoading = false;
              });
           }
        },
        cancelOnError: true,
      );


    } catch (e) {
       print('[ChatView] Error initiating stream: $e at ${DateTime.now()}');
       if (mounted) {
          setState(() {
            _generatedText = 'Error starting stream: $e';
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error connecting: $e'), backgroundColor: Colors.red),
          );
       }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Stack( // Using Stack for positioning back/logo buttons easily
              children: [
                Column(
                  children: [
                    const SizedBox(height: 60), // Space for top buttons
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        // Always display the container, SingleChildScrollView allows scrolling
                        child: Container(
                           width: double.infinity, // Ensure it takes full width
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: _generatedText.contains("[Error]") ? Colors.red[900]?.withOpacity(0.3) : Colors.grey[800], // Indicate error visually?
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: SingleChildScrollView( // Make text scrollable
                             child: SelectableText( // Use SelectableText for easy copying
                               _generatedText.isEmpty && !_isLoading ? 'Output will appear here...' : _generatedText,
                               style: TextStyle(
                                   fontSize: 16, color: _generatedText.isEmpty && !_isLoading ? Colors.white54 : Colors.white),
                             ),
                           ),
                         )
                      ),
                    ),
                    // Prompt input area
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _promptController,
                        minLines: 1, // Adjust as needed
                        maxLines: 5, // Adjust as needed
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your prompt...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey[800],
                           border: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(12),
                             borderSide: BorderSide.none, // Remove border if fillColor is used
                           ),
                           focusedBorder: OutlineInputBorder( // Optional: style when focused
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[900]!)
                          ),
                        ),
                      ),
                    ),
                    // Generate button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0), // Adjusted padding
                      child: SizedBox( // Make button take full width
                         width: double.infinity,
                         child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleGeneration, // Call the updated function
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              disabledBackgroundColor: Colors.grey[700], // Style for disabled state
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24, // Increased size slightly
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3, // Thicker stroke
                                        color: Colors.white),
                                  )
                                : const Text('Generate',
                                    style: TextStyle(fontSize: 18, color: Colors.white)), // Explicit color
                          ),
                      ),
                    ),
                  ],
                ),
                 // Positioned UI Elements (Back Button, Logo) - No changes needed here usually
                Positioned(
                  top: 20,
                  left: 10,
                  child: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, size: 30, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Add your CustomLogo back if you have it
                // Positioned(top: 20, right: 20, child: CustomLogo(size: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}