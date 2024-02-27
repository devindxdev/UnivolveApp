import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:univolve_app/pages/UserProfile/edit_profile.dart';
import 'package:univolve_app/pages/services/database_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

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

  // Create an instance of the UserService class
  final UserService _userService = UserService();
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    fetchAndSetUserDetails();
    //print user details
    print(userDetails);
  }

  void fetchAndSetUserDetails() async {
    userDetails = await _userService.fetchUserDetails();
    setState(() {});
  }

  void _showQrCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(userDetails!['username'] ?? 'Error')),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          // content: Container(
          //   child:
          content: PrettyQrView.data(
            data: userDetails!['universityId'] ?? 'Error',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If userDetails is null, show a loading indicator
    if (userDetails == null) {
      return const Center(
          child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading details...'),
        ],
      ));
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 24),
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(userDetails!['photoUrl'] ??
                  'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png'),
            ),
            const SizedBox(height: 16),
            Text(
              userDetails!['username'] ?? 'New User',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Text(
                userDetails!['bio'] ?? 'Bio not available',
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
                  onTap:
                      // Add action for sharing profile
                      () => _showQrCodeDialog(context),
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
                    // Add action for customizing bio
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(userData: userDetails!),
                      ),
                    );
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Customize Profile',
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
                      subtitle: Text(
                          userDetails!['program'] ?? 'Program not available',
                          style: _textStyleSubtitle)),
                  ListTile(
                    title: Text('Current Courses', style: _textStyleTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildCourseList(userDetails!['currentCourses']),
                    ),
                  ),
                  ListTile(
                    title: Text('Interests', style: _textStyleTitle),
                    subtitle: Text(
                      userDetails!['interests'] ?? '',
                      style: _textStyleSubtitle,
                    ),
                  ),
                  // Display the social media handles
                  ListTile(
                    title: Text('Social Media Handles'),
                    subtitle: Wrap(
                      spacing: 8.0, // Gap between adjacent chips.
                      runSpacing: 4.0, // Gap between lines.
                      children:
                          _buildSocialIcons(userDetails!['socialMediaHandles']),
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

  List<Widget> _buildCourseList(Map? courses) {
    // If courses is null or not a map, return empty list
    if (courses == null || courses is! Map) {
      return [Text('No courses available,style: _textStyleSubtitle')];
    }

    List<Widget> courseList = [];
    courses.forEach((key, value) {
      courseList.add(Text('$key - $value', style: _textStyleSubtitle));
    });
    return courseList;
  }

  List<Widget> _buildSocialIcons(Map? handles) {
    List<Widget> iconList = [];
    handles?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        IconData iconData = _getSocialIcon(key);
        iconList.add(
          GestureDetector(
            onTap: () => _launchURL(value.toString()),
            child: Icon(iconData),
          ),
        );
      }
    });
    return iconList;
  }

  IconData _getSocialIcon(String key) {
    switch (key) {
      case 'LinkedIn':
        return Icons.linked_camera; // Replace with actual LinkedIn icon
      case 'Instagram':
        return Icons.camera_alt; // Replace with actual Instagram icon
      case 'Github':
        return Icons.code; // Replace with actual Github icon
      // Add more cases for different social media
      default:
        return Icons.web; // Default icon for unknown social media
    }
  }

  void _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Handle the error or show a message if unable to launch URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $urlString'),
        ),
      );
    }
  }
}
