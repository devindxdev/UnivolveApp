import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:univolve_app/assets/univolve_icons_icons.dart';
import 'package:univolve_app/pages/services/database_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDrawer extends StatefulWidget {
  @override
  _UserDrawerState createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  final UserService _userService = UserService();
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() async {
    final name = await _userService.fetchUserName();
    setState(() => userName = name);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xff84C5BE),
      child: ListView(
        // The ListView here contains all the children directly, no nested ListView
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xff016D77),
                  Color(0xff84C5BE),
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png'),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "$userName",
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Profile', style: GoogleFonts.poppins()),
            leading: Icon(UnivolveIcons.profile),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: Text('Settings', style: GoogleFonts.poppins()),
            leading: Icon(Icons.settings),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            title: Text('About', style: GoogleFonts.poppins()),
            leading: Icon(Icons.info),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            title: Text('Sign Out', style: GoogleFonts.poppins()),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: Colors.black,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Quick TRU Links',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ],
            ),
          ),

          _createDrawerItem(
            icon: Icons.school,
            text: 'Moodle',
            onTap: () => _launchURL('https://moodle.tru.ca/login/index.php'),
          ),
          _createDrawerItem(
            icon: Icons.web,
            text: 'myTRU',
            onTap: () => _launchURL('https://mytru.tru.ca/'),
          ),
          _createDrawerItem(
            icon: Icons.calendar_today,
            text: 'Course Timetable',
            onTap: () => _launchURL(
                'https://reg-prod.ec.tru.ca/StudentRegistrationSsb/ssb/registrationHistory/registrationHistory'),
          ),
          _createDrawerItem(
            icon: Icons.description,
            text: 'View Transcript',
            onTap: () => _launchURL(
                'https://ssb-prod.ec.tru.ca/ssomanager/saml/login?relayState=/c/auth/SSB?pkg=bwskotrn.P_ViewTermTran'),
          ),
          _createDrawerItem(
            icon: Icons.assessment,
            text: 'Degree Works',
            onTap: () =>
                _launchURL('https://dw-prod.ec.tru.ca/responsiveDashboard'),
          ),
          _createDrawerItem(
            icon: Icons.account_balance_wallet,
            text: 'Financial Account Summary',
            onTap: () => _launchURL(
                'https://ssb-prod.ec.tru.ca/ssomanager/saml/login?relayState=/c/auth/SSB?pkg=bwskoacc.P_ViewAcct'),
          ),

          // Repeat for other drawer items
        ],
      ),
    );
  }

  Widget _createDrawerItem(
      {IconData? icon, String? text, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text!, style: GoogleFonts.poppins()),
      onTap: onTap,
    );
  }

  void _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $urlString';
    }
  }
}
