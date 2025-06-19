// lib/services/options_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// Assuming ApiService provides the base URL, otherwise define it here
// import 'api_service.dart'; // If ApiService has a static baseUrl
// OR:
const String _baseUrl = 'http://127.0.0.1:5001/api'; // Match your API prefix

class OptionsService {

  static final Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json", // Expect JSON responses
  };


  // Fetches all generation parameters for all models
  static Future<Map<String, Map<String, dynamic>>> fetchAllOptions() async {
    final Uri uri = Uri.parse('$_baseUrl/options/all'); // Correct endpoint path
    print('[OptionsService] Fetching all options from $uri'); // Debug log
    try {
      final response = await http.get(uri, headers: _headers);

      print('[OptionsService] Fetch response status: ${response.statusCode}'); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        // Ensure the structure is Map<String, Map<String, dynamic>>
         final Map<String, Map<String, dynamic>> result = {};
         decoded.forEach((key, value) {
           if (value is Map) {
             result[key] = Map<String, dynamic>.from(value);
           } else {
             // Handle unexpected structure if necessary, maybe log a warning
             print("Warning: Unexpected format for model '$key' options: $value");
             result[key] = {}; // Assign empty map as fallback
           }
         });
         print('[OptionsService] Successfully parsed options for ${result.length} models.'); // Debug log
         return result;
      } else {
        // Try parsing backend error detail
        String errorMsg = 'Failed to load options.';
        try {
           final errorJson = json.decode(response.body);
           if (errorJson['detail'] != null) {
              errorMsg = errorJson['detail'];
           } else {
              errorMsg = response.body; // Fallback to raw body
           }
        } catch (_) {
           errorMsg = response.body.isNotEmpty ? response.body : errorMsg; // Fallback to raw body
        }
        print('[OptionsService] Error loading options (${response.statusCode}): $errorMsg'); // Debug log
        throw Exception('$errorMsg Status: ${response.statusCode}');
      }
    } catch (e) {
      print('[OptionsService] Exception during fetchAllOptions: $e'); // Debug log
       // Improve error message detail if possible
       if (e is http.ClientException) {
          throw Exception('Network error: Failed to connect to the server.');
       } else if (e is FormatException) {
          throw Exception('Invalid response format received from server.');
       }
      throw Exception('Failed to connect or parse options: $e');
    }
  }

  // Updates generation parameters for a specific model
  static Future<Map<String, dynamic>> updateOptions(
      String modelId, Map<String, dynamic> params) async {
    // Ensure modelId is not empty
    if (modelId.isEmpty) {
        throw ArgumentError("Model ID cannot be empty.");
    }
    final Uri uri = Uri.parse('$_baseUrl/options/$modelId'); // Correct endpoint path
     print('[OptionsService] Updating options for $modelId at $uri'); // Debug log
    try {
      final response = await http.put(
        uri,
        headers: _headers, // Use common headers
        body: json.encode(params),
      );

      print('[OptionsService] Update response status: ${response.statusCode}'); // Debug log

      if (response.statusCode == 200) {
         final Map<String, dynamic> updatedParams = json.decode(response.body);
          print('[OptionsService] Successfully updated options for $modelId.'); // Debug log
         return updatedParams; // Return the updated params from the server
      } else {
         // Try parsing backend error detail
         String errorMsg = 'Failed to update options for $modelId.';
         try {
            final errorJson = json.decode(response.body);
            if (errorJson['detail'] != null) {
               errorMsg = errorJson['detail'];
            } else {
               errorMsg = response.body; // Fallback to raw body
            }
         } catch (_) {
            errorMsg = response.body.isNotEmpty ? response.body : errorMsg; // Fallback to raw body
         }
         print('[OptionsService] Error updating options for $modelId (${response.statusCode}): $errorMsg'); // Debug log
         throw Exception('$errorMsg Status: ${response.statusCode}');
      }
    } catch (e) {
      print('[OptionsService] Exception during updateOptions for $modelId: $e'); // Debug log
       // Improve error message detail if possible
       if (e is http.ClientException) {
          throw Exception('Network error: Failed to connect to the server.');
       } else if (e is FormatException) {
          throw Exception('Invalid request or response format.');
       }
      throw Exception('Failed to connect or update options: $e');
    }
  }
}