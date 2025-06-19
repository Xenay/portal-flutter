// lib/widgets/custom_logo.dart
import 'package:flutter/material.dart';
import 'dart:math' as math; // For rotation if needed


class CustomLogo extends StatelessWidget {
  final double size; // Allow specifying size

  const CustomLogo({Key? key, this.size = 50.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Define colors for the gradient - use primary and a related shade
    final gradientColor1 = colorScheme.primary; // E.g., a bright cyan/blue
    final gradientColor2 = Color.lerp(colorScheme.primary, Colors.black, 0.4) ?? colorScheme.primary; // Darker shade

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          // Subtle background for the container itself (optional)
          // color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(size * 0.2), // Rounded corners
          gradient: LinearGradient( // Subtle background gradient for depth
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: [
                const Color(0xFF1A1A1A), // Match dark background shades used elsewhere
                const Color(0xFF2C2C2C),
             ],
          ),
          border: Border.all( // A border suggesting the 'shell'
             color: colorScheme.primary.withOpacity(0.3),
             width: size * 0.03, // Scaled border width
           ),
           boxShadow: [ // Subtle glow effect using shadow
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.2),
              blurRadius: size * 0.1,
              spreadRadius: size * 0.02,
            ),
           ]
        ),
        child: Center(
          child: Container(
            width: size * 0.55, // Size of the inner core
            height: size * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient( // Glowing core effect
                center: Alignment.center,
                radius: 0.5, // Gradient covers the whole circle
                colors: [
                  gradientColor1.withOpacity(0.8), // Brighter center
                  gradientColor2.withOpacity(0.6), // Fades out
                ],
                stops: const [0.0, 1.0], // Gradient stops
              ),
              boxShadow: [ // Inner glow shadow
                 BoxShadow(
                    color: gradientColor1.withOpacity(0.5),
                    blurRadius: size * 0.15,
                    spreadRadius: 0,
                 ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}