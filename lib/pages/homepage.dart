import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:univolve_app/assets/univolve_icons_icons.dart';
import 'package:univolve_app/pages/assetUIElements/drawer.dart';
import 'package:univolve_app/pages/eventspage.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;
  String userName = "Loading..."; // Default text

  var userDetail;

  @override
  void initState() {
    final user = FirebaseAuth.instance.currentUser;
    userDetail = user?.email;
    fetchUserName();

    super.initState();
  }

  // Create a getter to obtain the user's email or a default string
  String get userEmail {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? "Not signed in";
  }

  void fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Assuming you use the user's UID to store and fetch user data
      // If you're using email or another field, adjust the query accordingly
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final querySnapshot = await usersCollection
          .where('email',
              isEqualTo: user
                  .email) // Adjust based on how you relate a user document to the FirebaseAuth user
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final universityId = userDoc.data()['universityId'] as String;

        // Now fetch the actual document using universityId
        final universityDoc = await usersCollection.doc(universityId).get();
        final name = universityDoc.data()?['name'] ?? "No name available";

        setState(() {
          userName = name;
        });
      } else {
        setState(() {
          userName = "User not found";
        });
      }
    } else {
      setState(() {
        userName = "Not signed in";
      });
    }
  }

  //list of pages
  late final List<Widget> _pages = <Widget>[
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Welcome to the chat page'),
          MaterialButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    ),
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Welcome to the notification page'),
          MaterialButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    ),
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Welcome to the home page'),
          MaterialButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    ),
    EventsPage(),
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Welcome to the profile page: $userEmail'),
          MaterialButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'U N I V O L V E',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          // leading: IconButton(
          //   icon:
          //       Icon(Icons.menu, color: Colors.white), // Custom icon and color
          //   onPressed: () {
          //     Scaffold.of(context).openDrawer();
          //   },
          // ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              color: Colors.white,
              onPressed: () {},
            ),
          ],
          centerTitle: true,
          backgroundColor: Color(0xff016D77),
          elevation: 0,
        ),
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
