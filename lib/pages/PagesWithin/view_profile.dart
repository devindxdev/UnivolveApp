import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewProfilePage extends StatelessWidget {
  final Map<String, dynamic>? user;

  ViewProfilePage({required this.user});

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
              backgroundImage: NetworkImage(
                user?['photoUrl'] ??
                    'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png',
              ),
            ),
            const SizedBox(height: 15),
            Text(
              user?['username'] ?? 'New User',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 0),
              child: Text(
                user?['bio'] ?? 'Bio not available',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
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
                      user?['program'] ?? 'Program not available',
                      style: _textStyleSubtitle,
                    ),
                  ),
                  ListTile(
                    title: Text('Current Courses', style: _textStyleTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildCourseList(user?['currentCourses']),
                    ),
                  ),
                  ListTile(
                    title: Text('Interests', style: _textStyleTitle),
                    subtitle: Text(
                      user?['interests'] ?? 'No interests provided',
                      style: _textStyleSubtitle,
                    ),
                  ),
                  ListTile(
                    title: Text('Social Media Handles', style: _textStyleTitle),
                    subtitle: Wrap(
                      spacing: 8.0, // Gap between adjacent chips.
                      runSpacing: 4.0, // Gap between lines.
                      children: _buildSocialIcons(user?['socialMediaHandles']),
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
    if (iconList.isEmpty)
      iconList.add(Text('No social media provided', style: _textStyleSubtitle));
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
      // Log error or inform user if unable to launch URL
      print('Could not launch $urlString');
    }
  }
}
