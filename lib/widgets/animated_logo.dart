import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({Key? key}) : super(key: key);

  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _pointerOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _pointerOffset = event.localPosition;
        });
      },
      onExit: (event) {
        setState(() {
          _pointerOffset = Offset.zero;
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Create a dynamic rotation for the gradient
          final double rotation = _controller.value * 2 * math.pi;

          // Calculate subtle tilt based on mouse position
          final double tiltX = (_pointerOffset.dy - 50) * 0.001;
          final double tiltY = -(_pointerOffset.dx - 100) * 0.001;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateX(tiltX)
              ..rotateY(tiltY)
              ..scale(1.0 + _pointerOffset.distance * 0.00005),
            child: Text(
              'Porta.ai',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: const [
                      Colors.blueAccent,
                      Colors.purpleAccent,
                      Colors.redAccent
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    transform: GradientRotation(rotation),
                  ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                shadows: const [
                  Shadow(
                    blurRadius: 8.0,
                    color: Colors.black45,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
