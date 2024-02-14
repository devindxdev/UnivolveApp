import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:univolve_app/assets/univolve_icons_icons.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;

  // Create a getter to obtain the user's email or a default string
  String get userEmail {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? "Not signed in";
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
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Welcome to the events page'),
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
        drawer: Drawer(
          backgroundColor: Color(0xff84C5BE),
          child: ListView(
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
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "$userEmail ",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Profile'),
                leading: Icon(UnivolveIcons.profile),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                title: Text('Settings'),
                leading: Icon(Icons.settings),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                title: Text('About'),
                leading: Icon(Icons.info),
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
              ListTile(
                title: Text('Sign Out'),
                leading: Icon(Icons.exit_to_app),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
        ),
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
