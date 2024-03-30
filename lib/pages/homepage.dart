import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:univolve_app/assets/univolve2_icons.dart';
import 'package:univolve_app/assets/univolve_icons_icons.dart';
import 'package:univolve_app/pages/PagesWithin/ai_bot.dart';
import 'package:univolve_app/pages/PagesWithin/search_user_page.dart';
import 'package:univolve_app/pages/assetUIElements/drawer.dart';
import 'package:univolve_app/pages/eventspage.dart';
import 'package:univolve_app/pages/home.dart';
import 'package:univolve_app/pages/notification_page.dart';
import 'package:univolve_app/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:univolve_app/pages/chat_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;
  String userName = "Loading..."; // Default text
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    fetchUserDataAndPreferences();
    super.initState();
  }

  Future<void> fetchUserDataAndPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final querySnapshot =
          await usersCollection.where('email', isEqualTo: user.email).get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        await updateUserPreferences(userData); // Update SharedPreferences
      }
    }
  }

  Future<void> updateUserPreferences(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert currentCourses and socialMediaHandles to JSON strings
    final currentCoursesJson = jsonEncode(userData['currentCourses']);
    final socialMediaHandlesJson = jsonEncode(userData['socialMediaHandles']);

    // Store each attribute in SharedPreferences
    await prefs.setString('bio', userData['bio']);
    await prefs.setString('currentCourses', currentCoursesJson);
    await prefs.setString('email', userData['email']);
    await prefs.setString('interests', userData['interests']);
    await prefs.setStringList(
        'likedEvents', List<String>.from(userData['likedEvents']));
    await prefs.setString('photoUrl', userData['photoUrl']);
    await prefs.setString('program', userData['program']);
    await prefs.setString('socialMediaHandles', socialMediaHandlesJson);
    await prefs.setString('universityId', userData['universityId']);
    await prefs.setString('username', userData['username']);
  }

  //list of pages
  late final List<Widget> _pages = <Widget>[
    ChatScreen(),
    NotificationsPage(),
    HomeScreen(),
    EventsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Univolve2.screenshot_2024_03_20_at_4_56_46_pm,
              color: Colors.black,
            ), // Custom icon
            onPressed: () {
              // Open the drawer
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Univolve2.searching_a_person),
              color: Colors.black,
              onPressed: () {
                // Add navigation to new page using navigator
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchUserPage()),
                );
              },
            ),
          ],
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),

        // Change the icon as needed

        drawer: UserDrawer(),
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GNav(
              selectedIndex: _selectedIndex,
              gap: 8,
              iconSize: 24,
              haptic: true,
              color: Color(0xff676D75),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              activeColor: Color(0xff016D77),
              tabBackgroundColor: Color(0xff84C5BE).withOpacity(0.4),
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              tabs: [
                GButton(
                  icon: UnivolveIcons.chat,
                  text: '',
                ),
                GButton(
                  icon: UnivolveIcons.notification,
                  text: '',
                ),
                GButton(
                  icon: UnivolveIcons.home,
                  text: '',
                ),
                GButton(
                  icon: UnivolveIcons.events,
                  text: '',
                ),
                GButton(
                  icon: UnivolveIcons.profile,
                  text: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
