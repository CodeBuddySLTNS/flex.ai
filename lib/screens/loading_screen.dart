import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RobotLoadingScreen extends StatelessWidget {
  const RobotLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // --- THE LOADING ANIMATION ---
            Center(
              child: CircularTextLoading(
                centerWidget: SvgPicture.asset(
                  'assets/images/flexai.svg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                text: "LOADING MODELS...",
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
                radius: 100,
              ),
            ),

            // Pushes the text to the bottom
            const Spacer(),

            // --- THE OWNER TEXT BELOW ---
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                "Powered by FlexAI © 2026",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ... (Rest of your CircularTextLoading code stays exactly the same) ...

class CircularTextLoading extends StatefulWidget {
  final Widget centerWidget;
  final String text;
  final TextStyle textStyle;
  final double radius;

  const CircularTextLoading({
    super.key,
    required this.centerWidget,
    required this.text,
    this.textStyle = const TextStyle(fontSize: 16, color: Colors.black),
    this.radius = 60,
  });

  @override
  State<CircularTextLoading> createState() => _CircularTextLoadingState();
}

class _CircularTextLoadingState extends State<CircularTextLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.centerWidget,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: SizedBox(
                width: widget.radius * 2,
                height: widget.radius * 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: _buildCircularCharacters(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildCircularCharacters() {
    final List<Widget> charWidgets = [];
    final chars = widget.text.split('');
    final double angleStep = 0.35;

    for (int i = 0; i < chars.length; i++) {
      final double angle = i * angleStep;

      charWidgets.add(
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(angle)
            ..translate(0.0, -widget.radius)
            ..rotateZ(0.0),
          child: Text(chars[i], style: widget.textStyle),
        ),
      );
    }
    return charWidgets;
  }
}
