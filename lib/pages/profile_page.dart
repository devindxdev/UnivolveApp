import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextStyle _textStyleTitle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  final TextStyle _textStyleSubtitle = GoogleFonts.poppins(
    fontSize: 14,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 24),
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage('URL_TO_YOUR_IMAGE'),
            ),
            SizedBox(height: 16),
            Text(
              'Jimil Hingu',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text(
                'Computer Science major with a passion for coding & innovation. Exploring the intersection of technology and creativity.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    // Add action for registering
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Share Profile',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xff016D77),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Add action for registering
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Customize Bio',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xff016D77),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Program', style: _textStyleTitle),
                    subtitle: Text('Bachelor of Science in Computer Science',
                        style: _textStyleSubtitle),
                  ),
                  ListTile(
                    title: Text('Current Courses', style: _textStyleTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('CSC 110 - Introduction to Computer Programming',
                            style: _textStyleSubtitle),
                        Text('CSC 220 - Data Structures and Algorithms',
                            style: _textStyleSubtitle),
                        Text('CSC 310 - Operating Systems',
                            style: _textStyleSubtitle),
                        Text('CSC 400 - Artificial Intelligence',
                            style: _textStyleSubtitle),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text('Interests', style: _textStyleTitle),
                    subtitle: Text(
                      '#MachineLearning #CyberSecurity #OpenSource #CloudComputing',
                      style: _textStyleSubtitle,
                    ),
                  ),
                  ListTile(
                    title: Text('Social Media Handles', style: _textStyleTitle),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.linked_camera),
                          onPressed: () {
                            // Add action for LinkedIn
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: () {
                            // Add action for Instagram
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.question_answer),
                          onPressed: () {
                            // Add action for other social media
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
