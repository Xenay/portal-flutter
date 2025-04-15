// lib/models/device_status_response.dart
import 'active_model_info.dart'; // Adjust import path if needed

class DeviceStatusResponse {
  final bool isModelLoaded;
  final ActiveModelInfo? activeModel;
  final String torchDevice;

  DeviceStatusResponse({
    required this.isModelLoaded,
    this.activeModel,
    required this.torchDevice,
  });

  factory DeviceStatusResponse.fromJson(Map<String, dynamic> json) {
    return DeviceStatusResponse(
      isModelLoaded: json['is_model_loaded'] as bool? ?? false, // Default to false if null
      activeModel: json['active_model'] != null
          ? ActiveModelInfo.fromJson(json['active_model'] as Map<String, dynamic>)
          : null,
      torchDevice: json['torch_device'] as String? ?? 'unknown', // Default if null
    );
  }
}