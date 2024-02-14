import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:univolve_app/assets/univolve_icons_icons.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //create current user
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to the home page: ' + user!.email.toString()),
            MaterialButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: GNav(
          gap: 8,
          iconSize: 24,
          haptic: true,
          color: Color(0xff676D75),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          duration: Duration(milliseconds: 300),
          activeColor: Color(0xff016D77),
          tabBackgroundColor: Color(0xff84C5BE).withOpacity(0.4),
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
    );
  }
}
