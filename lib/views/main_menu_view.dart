import 'package:ai_help/widgets/custom_logo.dart';
import 'package:flutter/material.dart';
// Assume you have a theme defined somewhere or define colors here
// import 'package:animated_gradient/animated_gradient.dart'; // Example package

// Placeholder for a potential logo/graphic widget
class PortalLogo extends StatelessWidget {
  final double size;
  const PortalLogo({Key? key, this.size = 150.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your actual logo or graphic
    return Icon(
      Icons.memory, // Placeholder: Represents the 'stick' hardware
      size: size,
      color: Theme.of(context).colorScheme.primary, // Use theme color
    );
  }
}

class MainMenuView extends StatelessWidget {
  const MainMenuView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Use a slightly off-black for better depth than Colors.black
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // --- Option 1: Subtle Gradient Background ---
          // AnimatedGradient( // Using example package 'animated_gradient'
          //   colors: [colorScheme.surface.withOpacity(0.8), colorScheme.surface],
          //   duration: const Duration(seconds: 5),
          // ),
          // --- Option 2: Static Textured/Abstract Background ---
          Container(color: const Color(0xFF0A0A0A)),

          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/1.jpg"), // Provide your asset
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.8), BlendMode.darken
                ),
              ),
            ),
          ),
          // --- Option 3: Simple Dark Background (as fallback) ---

          // --- Main Content Layout ---
          SafeArea( // Ensures content avoids notches/system areas
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                  children: [
                    const Spacer(flex: 2), // Push content down slightly
                    const CustomLogo(size: 120), // Central visual element
                    const SizedBox(height: 20),
                    Text(
                      'PORTAL',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      'The unknown is not the unobtainable',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(flex: 1),
                    _buildMainMenuButton(
                      context: context,
                      label: 'Enter Chat',
                      icon: Icons.chat_bubble_outline,
                      onPressed: () => Navigator.pushNamed(context, '/chat'),
                    ),
                    const SizedBox(height: 20),
                    _buildMainMenuButton(
                      context: context,
                      label: 'Manage Models', // Changed label for clarity
                      icon: Icons.dns_outlined, // Icon suggesting models/data
                      onPressed: () => Navigator.pushNamed(context, '/models'),
                    ),
                     const SizedBox(height: 20),
                    _buildMainMenuButton(
                      context: context,
                      label: 'Device & User', // Changed label for clarity
                      icon: Icons.usb_outlined, // Icon suggesting hardware
                      onPressed: () => Navigator.pushNamed(context, '/user'),
                    ),
                    const Spacer(flex: 3), // Push buttons up from bottom slightly
                  ],
                ),
              ),
            ),
          ),

          // Settings icon remains easily accessible
          Positioned(
            top: 40, // Adjust for safe area if needed
            right: 20,
            child: IconButton(
              icon: Icon(Icons.settings_outlined, size: 30, color: Colors.white.withOpacity(0.8)),
              tooltip: 'Settings & More', // Tooltip for Desktop/Web
              onPressed: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.8),
                  builder: (context) => const ModalMenu(), // Your existing modal menu
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build consistent menu buttons
  Widget _buildMainMenuButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Text and icon color
        backgroundColor: colorScheme.primary.withOpacity(0.15), // Subtle background
        minimumSize: const Size(500, 55), // Make buttons wide
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Consistent rounding
          side: BorderSide(
            color: colorScheme.primary.withOpacity(0.5), // Themed border
            width: 1,
          ),
        ),
        textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ).copyWith(
         // Subtle glow/overlay on hover/press (more effective on desktop)
         overlayColor: MaterialStateProperty.resolveWith<Color?>(
           (Set<MaterialState> states) {
             if (states.contains(MaterialState.hovered)) {
               return colorScheme.primary.withOpacity(0.1);
             }
             if (states.contains(MaterialState.pressed)) {
               return colorScheme.primary.withOpacity(0.2);
             }
             return null; // Defer to the default
           },
         ),
      ),
    );
  }
}

// --- ModalMenu (Minor Style Tweaks for Consistency) ---
// You can keep your ModalMenu mostly as is, maybe adjust colors
// slightly to use Theme.of(context).colorScheme if you define a theme.

class ModalMenu extends StatelessWidget {
 const ModalMenu({Key? key}) : super(key: key);
 @override
 Widget build(BuildContext context) {
   final theme = Theme.of(context);
   final colorScheme = theme.colorScheme;

   return Dialog(
     backgroundColor: const Color(0xFF1A1A1A), // Slightly lighter dark shade
     insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Rounded dialog
     child: Container(
       // Constrain width for larger screens if needed
       constraints: const BoxConstraints(maxWidth: 400),
       padding: const EdgeInsets.all(20),
       child: Column(
         mainAxisSize: MainAxisSize.min, // Don't take full height unless needed
         children: [
           Align(
             alignment: Alignment.topRight,
             child: IconButton(
               icon: Icon(Icons.close, color: Colors.white70, size: 28),
               onPressed: () => Navigator.pop(context),
             ),
           ),
           Text(
             'Menu',
             style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
           ),
           const SizedBox(height: 10),
           Divider(color: Colors.white.withOpacity(0.3)),
           const SizedBox(height: 10),
           _buildModalListTile(
             context: context,
             icon: Icons.person_outline,
             title: 'User Page',
             route: '/user',
           ),
           _buildModalListTile(
             context: context,
             icon: Icons.shopping_bag_outlined,
             title: 'Shop Page',
             route: '/shop',
           ),
           _buildModalListTile(
             context: context,
             icon: Icons.settings_outlined,
             title: 'Options Page',
             route: '/options',
           ),
           // Add other items like About, Logout etc. if needed
           const SizedBox(height: 10),
         ],
       ),
     ),
   );
 }

 // Helper for consistent ListTiles in the modal
 Widget _buildModalListTile({
   required BuildContext context,
   required IconData icon,
   required String title,
   required String route,
 }) {
   final theme = Theme.of(context);
   final colorScheme = theme.colorScheme;

   return ListTile(
     leading: Icon(icon, color: colorScheme.primary),
     title: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
     onTap: () {
       Navigator.pop(context); // Close the dialog first
       Navigator.pushNamed(context, route);
     },
     hoverColor: colorScheme.primary.withOpacity(0.1), // Subtle hover
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
   );
 }
}