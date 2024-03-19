import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffb2d8d8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/splash.png',
              width: 300, // Adjust the size as needed
              height: 200, // Adjust the size as needed
            ),
            Lottie.asset('assets/images/onboarding/onboard1.json', height: 300),
            SizedBox(height: 20), // Spacing between image and text
            Text(
              'Campus Events and Activities',
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10), // Spacing between heading and subheading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Explore and participate in campus events and activities with ease. Discover lectures, festivals, and more to stay connected with campus life.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
