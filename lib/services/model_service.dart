import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/model_info.dart';

class ModelService {
  static const String _baseUrl = 'http://127.0.0.1:5001'; // Your FastAPI URL

  // Fetch all models from /models
  // --- NEW Method: Fetch Models List ---
  static Future<List<ModelInfo>> fetchModels() async {
    final url = Uri.parse('$_baseUrl/models');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> modelsJson = data['models'] as List<dynamic>? ?? [];
        // Convert JSON list to List<ModelInfo>
        final List<ModelInfo> models = modelsJson
            .map((jsonItem) => ModelInfo.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        return models;
      } else {
        throw Exception('Failed to load models list. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in fetchModels: $e");
      throw Exception('Failed to connect or get models list: $e');
    }
  }

  // --- NEW Method: Install Model ---
  static Future<String> installModel(String modelId) async {
     final url = Uri.parse('$_baseUrl/models/install/$modelId');
     try {
       final response = await http.post(url);
       final Map<String, dynamic> data = json.decode(response.body);

       if (response.statusCode == 200) {
         return data['message'] as String? ?? 'Installation started.';
       } else {
          throw Exception(data['detail'] ?? 'Failed to install model. Status: ${response.statusCode}');
       }
     } catch (e) {
       print("Error in installModel: $e");
       throw Exception('Failed to run install command: $e');
     }
  }

  // --- NEW Method: Activate Model ---
   static Future<String> activateModel(String modelId) async {
     final url = Uri.parse('$_baseUrl/models/activate/$modelId');
     try {
       final response = await http.post(url);
       final Map<String, dynamic> data = json.decode(response.body);

       if (response.statusCode == 200) {
         return data['message'] as String? ?? 'Activation successful.';
       } else {
          throw Exception(data['detail'] ?? 'Failed to activate model. Status: ${response.statusCode}');
       }
     } catch (e) {
       print("Error in activateModel: $e");
       throw Exception('Failed to run activate command: $e');
     }
  }

   // --- NEW Method: Delete Model ---
   static Future<String> deleteModel(String modelId) async {
     final url = Uri.parse('$_baseUrl/models/$modelId');
      try {
       final response = await http.delete(url);
       final Map<String, dynamic> data = json.decode(response.body);

       if (response.statusCode == 200) {
         return data['message'] as String? ?? 'Deletion successful.';
       } else {
          throw Exception(data['detail'] ?? 'Failed to delete model. Status: ${response.statusCode}');
       }
     } catch (e) {
       print("Error in deleteModel: $e");
       throw Exception('Failed to run delete command: $e');
     }
  }
}
