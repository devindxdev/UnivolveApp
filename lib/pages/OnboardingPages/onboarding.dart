import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:univolve_app/pages/AllAuthPages/auth_page.dart';
import 'package:univolve_app/pages/OnboardingPages/onboarding_page4.dart';
import 'package:univolve_app/pages/OnboardingPages/onboarding_page5.dart';
import 'package:univolve_app/pages/OnboardingPages/onboarding_page6.dart';
import 'onboarding_page1.dart'; // Make sure to create and import this
import 'onboarding_page2.dart'; // Make sure to create and import this
import 'onboarding_page3.dart'; // Make sure to create and import this

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  final int _totalPages = 6;
  bool _onLastPage = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _onLastPage = _controller.page == _totalPages - 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _onLastPage = index == _totalPages - 1;
              });
            },
            children: [
              OnboardingPage1(),
              OnboardingPage2(),
              OnboardingPage3(),
              OnboardingPage4(),
              OnboardingPage5(),
              OnboardingPage6(),
            ],
          ),

          // Bottom slider dots, skip, and next/done
          Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip button
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(_totalPages - 1);
                  },
                  child: Text('Skip', style: GoogleFonts.poppins()),
                ),

                // Dot indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: _totalPages,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Color(0xff006d77),
                    dotColor: Color(0xff006d77).withOpacity(0.8),
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 10,
                  ),
                ),

                // Next or Get Started button
                if (!_onLastPage)
                  GestureDetector(
                    onTap: () {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Text('Next', style: GoogleFonts.poppins()),
                  )
                else
                  GestureDetector(
                    onTap: () async {
                      // At the end of your onboarding flow
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('hasSeenOnboarding', true);
                      // Navigate to AuthPage

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AuthPage()), // Adjust the navigation target
                      );
                    },
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }
}
