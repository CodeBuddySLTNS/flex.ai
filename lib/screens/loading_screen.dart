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

            Center(
              child: SvgPicture.asset(
                'assets/images/flexai.svg',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),

            const Spacer(),

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
