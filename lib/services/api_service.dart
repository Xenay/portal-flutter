import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/device_status_response.dart';
import '../models/system_info_response.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:5001';

static Future<Map<String, dynamic>> generateText(String prompt, {int maxNewTokens = 256}) async { // Add optional parameter
    final url = Uri.parse('$_baseUrl/generate');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        // Encode both prompt and max_new_tokens
        body: json.encode({
            'prompt': prompt,
            'max_new_tokens': maxNewTokens, // Send the value
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body); // Decode once

      if (response.statusCode == 200) {
        return data; // Return the decoded map
      } else {
        // Use the detail field from the JSON error response if available
        String errorMsg = data['detail'] ?? 'Failed to generate text.';
        throw Exception('$errorMsg Status: ${response.statusCode}');
      }
    } catch (e) {
      // Catch network errors, JSON decoding errors, or other exceptions
      print("Error in generateText API call: $e");
      // Improve error message detail if possible
      if (e is http.ClientException) {
          throw Exception('Network error: Failed to connect to the server.');
      } else if (e is FormatException) {
          throw Exception('Invalid response format received from server.');
      }
      throw Exception('Failed to generate text: $e');
    }
  }

  // --- NEW Method: Get Device Status ---
  static Future<DeviceStatusResponse> getDeviceStatus() async {
    final url = Uri.parse('$_baseUrl/status');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return DeviceStatusResponse.fromJson(data);
      } else {
         throw Exception('Failed to load device status. Status: ${response.statusCode}');
      }
    } catch (e) {
       print("Error in getDeviceStatus: $e");
       throw Exception('Failed to connect or get device status: $e');
    }
  }

  // --- NEW Method: Get System Info ---
  static Future<SystemInfoResponse> getSystemInfo() async {
    final url = Uri.parse('$_baseUrl/system/info');
     try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SystemInfoResponse.fromJson(data);
      } else {
        throw Exception('Failed to load system info. Status: ${response.statusCode}');
      }
    } catch (e) {
       print("Error in getSystemInfo: $e");
       throw Exception('Failed to connect or get system info: $e');
    }
  }
  static Stream<String> generateTextStream(String prompt, {int maxNewTokens = 1024}) async* { // Use async*
    final client = http.Client();
    final url = Uri.parse('$_baseUrl/generate/stream'); // STREAMING endpoint path
    final request = http.Request('POST', url);
    request.headers['Content-Type'] = 'application/json; charset=UTF-8';
    request.headers['Accept'] = 'text/plain';
    request.body = json.encode({
      'prompt': prompt,
      'max_new_tokens': maxNewTokens,
    });

    print('[ApiService async*] Starting stream request to $url at ${DateTime.now()}');
    http.StreamedResponse? streamedResponse; // Declare outside try

    try {
      streamedResponse = await client.send(request);
      print('[ApiService async*] Received response status: ${streamedResponse.statusCode} at ${DateTime.now()}');

      if (streamedResponse.statusCode == 200) {
        int chunkCount = 0;
        // Directly yield chunks from the decoded stream
        await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
          chunkCount++;
          print('[ApiService async*] Yielding chunk $chunkCount (${chunk.length} chars) at ${DateTime.now()}');
          yield chunk; // Use yield to push data into the stream returned by this function
        }
        print('[ApiService async*] Stream finished successfully at ${DateTime.now()}');
      } else {
        // Handle non-200 status codes
        final errorBody = await streamedResponse.stream.bytesToString(); // Consume stream body
         print('[ApiService async*] Received error status: ${streamedResponse.statusCode}, Body: $errorBody at ${DateTime.now()}');
        String errorMsg = 'Failed to generate stream.';
        try {
          final Map<String, dynamic> errorData = json.decode(errorBody);
          errorMsg = errorData['detail'] ?? errorMsg;
        } catch (_) {
          errorMsg = errorBody.isNotEmpty ? errorBody : errorMsg;
        }
        // Throw an exception which will be caught by the listener's onError in ChatView
        throw Exception('$errorMsg Status: ${streamedResponse.statusCode}');
      }
    } catch (e, stackTrace) {
      // Catch setup errors or errors during the stream processing
       print("[ApiService async*] Error during stream request/processing: $e\n$stackTrace at ${DateTime.now()}");
      // Re-throw the exception to be handled by the UI listener's onError
      throw Exception('Stream failed: $e');
    } finally {
      // This finally block now correctly executes only after the 'await for' loop
      // finishes (onDone) or an error is thrown.
      print("[ApiService async*] Closing HTTP client at ${DateTime.now()}");
      client.close();
    }
  }

  // --- Add methods for other endpoints (/models, /models/install, etc.) here ---
  // Example:
  // static Future<ModelListResponse> getModels() async { ... }
  // static Future<void> activateModel(String modelId) async { ... }
  // static Future<void> installModel(String modelId) async { ... }
  // static Future<void> deleteModel(String modelId) async { ... }
}