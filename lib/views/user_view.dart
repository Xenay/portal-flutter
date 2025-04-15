// lib/views/user_view.dart
import 'package:flutter/material.dart';

// Import the service and models (adjust paths)
import '../services/api_service.dart';
import '../models/device_status_response.dart';
import '../models/system_info_response.dart';

class UserView extends StatefulWidget {
  const UserView({Key? key}) : super(key: key);

  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  Future<Map<String, dynamic>>? _userDataFuture; // Combined future
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch both status and system info concurrently
  Future<void> _loadUserData() async {
    setState(() {
      _errorMessage = null; // Clear previous errors
      // Use a Future that resolves to a Map containing both results
      _userDataFuture = _fetchCombinedData();
    });
  }

  // Helper function to fetch data concurrently
  Future<Map<String, dynamic>> _fetchCombinedData() async {
    try {
      final results = await Future.wait([
        ApiService.getDeviceStatus(),
        ApiService.getSystemInfo(),
      ]);
      // Return data in a map for easy access in FutureBuilder
      return {
        'status': results[0] as DeviceStatusResponse,
        'system': results[1] as SystemInfoResponse,
      };
    } catch (e) {
       print("Error fetching user data: $e");
       // Set error message to display in the UI
       setState(() {
         _errorMessage = e.toString();
       });
       // Re-throw to let FutureBuilder handle the error state
       rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Device & User'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData, // Allow pull-to-refresh
        color: colorScheme.primary,
        backgroundColor: const Color(0xFF1A1A1A),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: colorScheme.primary));
            } else if (snapshot.hasError || _errorMessage != null) {
              // Display error message if fetching failed
              return _buildErrorWidget('Error loading data: ${_errorMessage ?? snapshot.error}');
            } else if (snapshot.hasData) {
              // Data loaded successfully, extract it
              final deviceStatus = snapshot.data!['status'] as DeviceStatusResponse;
              final systemInfo = snapshot.data!['system'] as SystemInfoResponse;

              // Build the UI with the fetched data
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildDeviceInfoCard(theme, colorScheme, deviceStatus),
                  const SizedBox(height: 20),
                  _buildSystemCheckCard(theme, colorScheme, systemInfo, deviceStatus.isModelLoaded),
                  const SizedBox(height: 20),
                  _buildActionsCard(theme, colorScheme), // Actions remain the same for now
                ],
              );
            } else {
              // Fallback for unexpected state
              return _buildErrorWidget('No data loaded. Pull to refresh.');
            }
          },
        ),
      ),
    );
  }

  // Helper to display error messages
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
               onPressed: _loadUserData,
             ),
           ],
         ),
       ),
     );
  }

  // Updated Card showing Portal device status from API data
  Widget _buildDeviceInfoCard(ThemeData theme, ColorScheme colorScheme, DeviceStatusResponse status) {
    final bool isConnected = status.isModelLoaded; // Use isModelLoaded as connection status proxy
    final activeModel = status.activeModel;

    return Card(
      color: const Color(0xFF1C1C1C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Status', // Renamed slightly
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: Icon(
                // Use a brain or memory icon instead of USB?
                isConnected ? Icons.memory : Icons.device_unknown,
                color: isConnected ? Colors.greenAccent : Colors.orangeAccent,
                size: 28,
              ),
              title: Text(
                isConnected ? 'Model Loaded & Active' : 'No Active Model',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              subtitle: Text(
                isConnected ? 'Device: ${status.torchDevice.toUpperCase()}' : 'Backend running, but no model loaded.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ),
            if (isConnected && activeModel != null) ...[
              const Divider(color: Colors.white24, height: 30),
              _buildDetailRow(theme, 'Active Model:', activeModel.name ?? 'N/A'),
              _buildDetailRow(theme, 'Model ID:', activeModel.id ?? 'N/A'),
              if (activeModel.description != null && activeModel.description!.isNotEmpty)
                 _buildDetailRow(theme, 'Description:', activeModel.description!),

              // Optionally add repo URL if needed
              // _buildDetailRow(theme, 'Repo URL:', activeModel.repoUrl ?? 'N/A'),
            ] else if (isConnected && activeModel == null) ... [
               // Should not happen if isModelLoaded is true, but handle defensively
               const Divider(color: Colors.white24, height: 30),
               Text("Status inconsistency: Model loaded but info unavailable.", style: TextStyle(color: Colors.redAccent)),
            ]
          ],
        ),
      ),
    );
  }

   // Helper for consistent detail rows
  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             label,
             style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70),
           ),
           const SizedBox(height: 2),
           Text(
             value,
             style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
           ),
         ],
      ),
    );
  }


  // Updated Card showing system check and recommendations from API data
  Widget _buildSystemCheckCard(ThemeData theme, ColorScheme colorScheme, SystemInfoResponse systemInfo, bool isModelLoaded) {
    String recommendation = 'Load a model to see recommendations.';
    Color recommendationColor = Colors.white70;
    final double? totalRam = systemInfo.totalRamGb;

    // Only calculate recommendation if a model is loaded (context matters)
    // and RAM info is available
    if (isModelLoaded && totalRam != null) {
      if (totalRam >= 15.5) { // Slightly adjusted threshold
        recommendation = 'Your system RAM (${totalRam.toStringAsFixed(1)} GB) is suitable for large models (13B+).';
        recommendationColor = Colors.greenAccent;
      } else if (totalRam >= 7.5) {
        recommendation = 'Your system RAM (${totalRam.toStringAsFixed(1)} GB) is suitable for standard models (~7B).';
        recommendationColor = Colors.yellowAccent.shade700;
      } else {
        recommendation = 'Your system RAM (${totalRam.toStringAsFixed(1)} GB) is limited. Smaller or heavily quantized models advised.';
        recommendationColor = Colors.orangeAccent;
      }
    } else if (!isModelLoaded && totalRam != null){
       recommendation = 'System RAM: ${totalRam.toStringAsFixed(1)} GB. Load a model for specific advice.';
    } else if (!isModelLoaded && totalRam == null){
       recommendation = 'RAM info unavailable (psutil needed?). Load model for basic advice.';
    }

    return Card(
      color: const Color(0xFF1C1C1C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Information',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildDetailRow(theme, 'CPU Info:', systemInfo.cpuInfo),
            _buildDetailRow(theme, 'Total RAM:',
               totalRam != null ? '${totalRam.toStringAsFixed(1)} GB' : 'N/A (psutil?)'
            ),
             _buildDetailRow(theme, 'Available RAM:',
               systemInfo.availableRamGb != null ? '${systemInfo.availableRamGb!.toStringAsFixed(1)} GB' : 'N/A (psutil?)'
            ),
            _buildDetailRow(theme, 'GPU Info:', systemInfo.gpuInfo ?? 'N/A'),
            _buildDetailRow(theme, 'CUDA Available:', systemInfo.isCudaAvailable ? 'Yes' : 'No'),

            const Divider(color: Colors.white24, height: 30),
            Text(
              'Model Recommendation:',
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 5),
            Text(
              recommendation,
              style: theme.textTheme.bodyMedium?.copyWith(color: recommendationColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              'Note: Actual performance also depends heavily on model quantization and specific CPU/GPU capabilities.',
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.white54, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // Card for actions - remains largely the same, linking to other views
  Widget _buildActionsCard(ThemeData theme, ColorScheme colorScheme) {
     // (Keep the _buildActionsCard implementation from the previous Flutter code example)
     // ... (ensure onTap navigates correctly, e.g., to '/models', '/shop') ...
     // Example ListTile:
      return Card(
       color: const Color(0xFF1C1C1C),
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       elevation: 2,
       child: Padding(
         padding: const EdgeInsets.symmetric(vertical: 8.0),
         child: Column(
           children: [
             ListTile(
                leading: Icon(Icons.download_for_offline_outlined, color: colorScheme.primary),
                title: Text('Manage / Download Models', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                onTap: () => Navigator.pushNamed(context, '/models'), // Ensure route exists
                hoverColor: colorScheme.primary.withOpacity(0.1),
             ),
             ListTile(
               leading: Icon(Icons.storefront_outlined, color: colorScheme.primary),
               title: Text('View Purchase Options', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
               subtitle: Text('Explore hardware tiers & software', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
               trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
               onTap: () => Navigator.pushNamed(context, '/shop'), // Ensure route exists
               hoverColor: colorScheme.primary.withOpacity(0.1),
             ),
             ListTile(
               leading: Icon(Icons.system_update_alt, color: colorScheme.primary),
                title: Text('Check for Updates', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
               trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                onTap: () {
                  // Implement update check logic if applicable
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checking for updates... (Placeholder)')),
                  );
                },
               hoverColor: colorScheme.primary.withOpacity(0.1),
              ),
           ],
         ),
       ),
     );
  }
}