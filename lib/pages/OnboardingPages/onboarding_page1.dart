import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffb2d8d8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //text for title here:
              Text(
                'Campus Events and Activities',
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              Lottie.network(
                  'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/onboarding/onboard1.json',
                  height: 300),
              // Spacing between image and text

              SizedBox(height: 10), // Spacing between heading and subheading
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                //subtext here:
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
      ),
    );
  }
}
