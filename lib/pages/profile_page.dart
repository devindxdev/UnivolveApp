import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:univolve_app/assets/univolve2_icons.dart';

import 'package:univolve_app/assets/univolve_icons_icons.dart';
import 'package:univolve_app/pages/PagesWithin/edit_profile.dart';
import 'package:univolve_app/pages/PagesWithin/show_friends_page.dart';
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
    if (mounted) {
      setState(() {});
    }
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
            const SizedBox(height: 15),
            Text(
              userDetails!['username'] ?? 'New User',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ShowFriendsPage(
                                universityId: userDetails!['universityId'])));
                  },
                  child: Text(
                    '${userDetails!['friendsCount'].toString()} Friends',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Add navigation to the EditProfilePage
                    // Navigator.push(context, MaterialPageRoute(builder: (_) {
                    //   return EditProfilePage(userData: userDetails);
                    // }));
                  },
                  child: Text(
                    (userDetails!['truClub'].isNotEmpty)
                        ? '|  ' + userDetails!['truClub']
                        : '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 0),
              child: Text(
                userDetails!['bio'] ?? 'Bio not available',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap:
                      // Add action for sharing profile
                      () => _showQrCodeDialog(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xff016D77),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.share, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Share Profile',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    // Wait for the EditProfilePage to pop and check if the profile was updated
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(userData: userDetails!),
                      ),
                    );

                    // If result is true, refresh the user details
                    if (result == true) {
                      fetchAndSetUserDetails();
                    }
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Univolve2.paint_board_and_brush,
                            color: Colors.white),
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
                      userDetails!['interests'] ?? 'No interests provided',
                      style: _textStyleSubtitle,
                    ),
                  ),
                  // Display the social media handles
                  ListTile(
                    title: Text('Social Media Handles', style: _textStyleTitle),
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
      return [Text('No courses available', style: _textStyleSubtitle)];
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
      if (iconList.isEmpty)
        iconList
            .add(Text('No social media provided', style: _textStyleSubtitle));
    });
    return iconList;
  }

  IconData _getSocialIcon(String key) {
    switch (key) {
      case 'LinkedIn':
        return Univolve2.linkedin;
      case 'Instagram':
        return Univolve2.instagram;
      case 'Github':
        return Univolve2.profile_1;
      default:
        return Icons.link_rounded;
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
