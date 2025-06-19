import 'package:ai_help/widgets/custom_logo.dart';
import 'package:flutter/material.dart';

// Animated glow wrapper for the logo
class AnimatedLogoGlow extends StatefulWidget {
  final double size;
  const AnimatedLogoGlow({Key? key, this.size = 150.0}) : super(key: key);

  @override
  _AnimatedLogoGlowState createState() => _AnimatedLogoGlowState();
}

class _AnimatedLogoGlowState extends State<AnimatedLogoGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _spread;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _spread = Tween<double>(begin: 8, end: 24).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withOpacity(0.6);
    return AnimatedBuilder(
      animation: _spread,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              spreadRadius: _spread.value,
              blurRadius: _spread.value * 1.5,
            ),
          ],
        ),
        child: child,
      ),
      child: CustomLogo(size: widget.size),
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
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          Container(color: const Color(0xFF0A0A0A)),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/1.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.8),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Animated glow around the logo
                    const AnimatedLogoGlow(size: 240),
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
                      label: 'Manage Models',
                      icon: Icons.dns_outlined,
                      onPressed: () => Navigator.pushNamed(context, '/models'),
                    ),
                     const SizedBox(height: 20),
                    _buildMainMenuButton(
                      context: context,
                      label: 'Device & User',
                      icon: Icons.usb_outlined,
                      onPressed: () => Navigator.pushNamed(context, '/user'),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.settings_outlined, size: 30, color: Colors.white.withOpacity(0.8)),
              tooltip: 'Settings & More',
              onPressed: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.8),
                  builder: (context) => const ModalMenu(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
        foregroundColor: Colors.white,
        backgroundColor: colorScheme.primary.withOpacity(0.15),
        minimumSize: const Size(500, 55),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ).copyWith(
         overlayColor: MaterialStateProperty.resolveWith<Color?>(
           (Set<MaterialState> states) {
             if (states.contains(MaterialState.hovered)) {
               return colorScheme.primary.withOpacity(0.1);
             }
             if (states.contains(MaterialState.pressed)) {
               return colorScheme.primary.withOpacity(0.2);
             }
             return null;
           },
         ),
      ),
    );
  }
}

class ModalMenu extends StatelessWidget {
 const ModalMenu({Key? key}) : super(key: key);
 @override
 Widget build(BuildContext context) {
   final theme = Theme.of(context);
   final colorScheme = theme.colorScheme;

   return Dialog(
     backgroundColor: const Color(0xFF1A1A1A),
     insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
     child: Container(
       constraints: const BoxConstraints(maxWidth: 400),
       padding: const EdgeInsets.all(20),
       child: Column(
         mainAxisSize: MainAxisSize.min,
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
           const SizedBox(height: 10),
         ],
       ),
     ),
   );
 }

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
       Navigator.pop(context);
       Navigator.pushNamed(context, route);
     },
     hoverColor: colorScheme.primary.withOpacity(0.1),
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
   );
 }
}
