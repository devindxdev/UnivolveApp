import 'package:flutter/material.dart';

class OnboardingPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff93C9C9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/onboarding_image.jpg',
              width: 300, // Adjust the size as needed
              height: 200, // Adjust the size as needed
            ),
            SizedBox(height: 20), // Spacing between image and text
            Text(
              'Welcome to Univolve2',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10), // Spacing between heading and subheading
            Text(
              'Enhance your university experience with our comprehensive platform.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
