import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:univolve_app/pages/PagesWithin/show_friends_page.dart';
import 'package:univolve_app/pages/assetUIElements/connectButton.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewProfilePage extends StatefulWidget {
  final Map<String, dynamic>? user;

  ViewProfilePage({super.key, required this.user});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  final TextStyle _textStyleTitle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  bool isFriend = false; // Tracks if the viewed user is a friend

  @override
  void initState() {
    super.initState();
    checkFriendStatus();
  }

// Checks if the current user is friends with the viewed user
  void checkFriendStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (userDoc.exists &&
        userDoc.data()!['friends'].contains(widget.user?['universityId'])) {
      setState(() => isFriend = true);
    }
  }

  final TextStyle _textStyleSubtitle = GoogleFonts.poppins(
    fontSize: 14,
  );

  // Implement addFriend and unfriendUser functions based on your Firebase structure
  void addFriend() async {
    // Logic to add the viewed user to the current user's friend list
  }

  void unfriendUser() async {
    // Logic to remove the viewed user from the current user's friend list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 24),
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(
                widget.user?['photoUrl'] ??
                    'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png',
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.user?['username'] ?? 'New User',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 0),
              child: Text(
                widget.user?['bio'] ?? 'Bio not available',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ),
            // Add row for friends count and club info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShowFriendsPage(
                            universityId: widget.user!['universityId']),
                      ),
                    );
                  },
                  child: Text(
                    '${widget.user!['friendsCount'] != null ? widget.user!['friendsCount'].toString() : '0'} Friends',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Column(
                            children: [
                              Text(
                                widget.user!['truClub'] ?? 'Club Name',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500, fontSize: 24),
                              ),
                              SizedBox(height: 18),
                              Text(
                                'Position in the Club:',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              Text(
                                widget.user!['positionInClub'] ??
                                    'Position not available',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
                  },
                  child: Text(
                    (widget.user != null &&
                            widget.user!['truClub'] != null &&
                            widget.user!['truClub'].isNotEmpty)
                        ? '|  ' + widget.user!['truClub']
                        : '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),
            GestureDetector(
              onTap: isFriend
                  ? unfriendUser
                  : addFriend, // Change the function based on isFriend
              child: Container(
                height: 40,
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xff016D77),
                ),
                child: Center(
                  child: Row(
                    children: <Widget>[
                      Text(
                          isFriend
                              ? '   Unfriend'
                              : '   Add Friend', // Change the text based on isFriend
                          style: GoogleFonts.poppins(color: Colors.white)),
                      SizedBox(width: 5),
                      Icon(
                        Icons
                            .person_add, // Consider changing the icon based on isFriend
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Program', style: _textStyleTitle),
                    subtitle: Text(
                      widget.user?['program'] ?? 'Program not available',
                      style: _textStyleSubtitle,
                    ),
                  ),
                  ListTile(
                    title: Text('Current Courses', style: _textStyleTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildCourseList(widget.user?['currentCourses']),
                    ),
                  ),
                  ListTile(
                    title: Text('Interests', style: _textStyleTitle),
                    subtitle: Text(
                      widget.user?['interests'] ?? 'No interests provided',
                      style: _textStyleSubtitle,
                    ),
                  ),
                  ListTile(
                    title: Text('Social Media Handles', style: _textStyleTitle),
                    subtitle: Wrap(
                      spacing: 8.0, // Gap between adjacent chips.
                      runSpacing: 4.0, // Gap between lines.
                      children:
                          _buildSocialIcons(widget.user?['socialMediaHandles']),
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
    });
    if (iconList.isEmpty) {
      iconList.add(Text('No social media provided', style: _textStyleSubtitle));
    }
    return iconList;
  }

  IconData _getSocialIcon(String key) {
    switch (key) {
      case 'LinkedIn':
        return Icons.link; // Placeholder, update with LinkedIn icon
      case 'Instagram':
        return Icons.camera_alt; // Placeholder, update with Instagram icon
      case 'Github':
        return Icons.code; // Placeholder, update with Github icon
      default:
        return Icons.web; // Default icon for unknown social media
    }
  }

  void _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Log error or inform user if unable to launch URL show snackbar
      // ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      //   SnackBar(
      //     content: Text("Unable to open URL"),
      //   ),
      // );
    }
  }
}
