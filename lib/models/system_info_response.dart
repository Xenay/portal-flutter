// lib/models/system_info_response.dart
class SystemInfoResponse {
  final String cpuInfo;
  final double? totalRamGb;
  final double? availableRamGb;
  final String? gpuInfo;
  final bool isCudaAvailable;

  SystemInfoResponse({
    required this.cpuInfo,
    this.totalRamGb,
    this.availableRamGb,
    this.gpuInfo,
    required this.isCudaAvailable,
  });

  factory SystemInfoResponse.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert num (int or double) to double?
    double? _toDouble(dynamic value) {
       if (value is num) {
         return value.toDouble();
       }
       return null;
    }

    return SystemInfoResponse(
      cpuInfo: json['cpu_info'] as String? ?? 'Unknown CPU',
      totalRamGb: _toDouble(json['total_ram_gb']),
      availableRamGb: _toDouble(json['available_ram_gb']),
      gpuInfo: json['gpu_info'] as String?,
      isCudaAvailable: json['is_cuda_available'] as bool? ?? false,
    );
  }
}