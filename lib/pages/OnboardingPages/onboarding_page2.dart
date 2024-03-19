import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff93C9C9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Connect with Peers',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            Lottie.network(
              'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/onboarding/onboard2.json',
              height: 300,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Find and connect with students who share your interests and courses. Our platform makes it easy to expand your social circle at university.',
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
