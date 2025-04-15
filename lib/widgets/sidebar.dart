// lib/widgets/sidebar.dart
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart'; // Keep using velocity_x as requested
import '../views/main_menu_view.dart';
import 'custom_logo.dart'; // Assuming this is your logo widget

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  // Helper for consistent ListTile styling
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required String currentRoute, // Pass current route
    required String itemRoute, // Route this item navigates to
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isSelected = currentRoute == itemRoute; // Check if selected

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : Colors.white70, // Highlight selected icon
        size: 22, // Slightly smaller icons
      ),
      title: title.text.color(isSelected ? Colors.white : Colors.white70).make(), // Highlight selected text
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: colorScheme.primary.withOpacity(0.15), // Background for selected
      hoverColor: Colors.white.withOpacity(0.1), // Hover effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded shape
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Adjust padding
      dense: true, // Make tiles less tall
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Get current route name to highlight the active item
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return VxBox(
      // Use VStack from velocity_x
      child: VStack(
        [
          // Logo - Keep as is, maybe adjust padding/size if needed
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/'), // Navigate to home
            child: CustomLogo() // Replace with your actual logo if needed
                .box
                .width(50)
                .height(50)
                .makeCentered()
                .pSymmetric(v: 24, h: 16), // Adjusted padding
          ),

          // Navigation Items using the helper
          _buildNavItem(
            context: context,
            icon: Icons.chat_bubble_outline, // Use outlined icons
            title: "Chat",
            onTap: () => Navigator.pushReplacementNamed(context, '/chat'), // Use pushReplacement if sidebar persists
            currentRoute: currentRoute ?? '',
            itemRoute: '/chat',
          ),
          const SizedBox(height: 4), // Spacing between items
          _buildNavItem(
            context: context,
            icon: Icons.model_training_outlined, // Use outlined icons
            title: "Models",
            onTap: () => Navigator.pushReplacementNamed(context, '/models'),
            currentRoute: currentRoute ?? '',
            itemRoute: '/models',
          ),
           const SizedBox(height: 4),
          _buildNavItem(
            context: context,
            icon: Icons.usb_outlined, // Icon for user/device page
            title: "Device & User",
            onTap: () => Navigator.pushReplacementNamed(context, '/user'),
            currentRoute: currentRoute ?? '',
            itemRoute: '/user',
          ),
          // Add more items here following the pattern...

          const Spacer(), // Pushes settings to the bottom

          // Settings Item (doesn't navigate, opens modal/dialog?)
          _buildNavItem(
            context: context,
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {
              // Maybe open the ModalMenu from MainMenuView?
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.8),
                // Assuming ModalMenu widget exists and is defined as before
                builder: (context) => const ModalMenu(), // Need to import ModalMenu
              );
            },
            // Settings is not a route, so it won't be selected based on route name
            currentRoute: currentRoute ?? '',
            itemRoute: '/settings_action', // Use a unique dummy route name
          ),
        ],
        crossAlignment: CrossAxisAlignment.stretch, // Ensure ListTiles stretch
      ).pSymmetric(v: 8, h: 12), // Padding inside the VStack
    )
    .color(const Color(0xFF1A1A1A)) // Use the dark background color
    .width(230) // Adjusted width slightly
    .make();
  }
}

// Ensure you have this import if ModalMenu is in a different file
// import '../views/main_menu_view.dart'; // Or wherever ModalMenu is defined