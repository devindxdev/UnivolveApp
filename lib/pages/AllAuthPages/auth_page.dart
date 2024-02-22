import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:univolve_app/pages/homepage.dart';
import 'package:univolve_app/pages/AllAuthPages/login_page.dart';
import 'package:univolve_app/pages/AllAuthPages/switch_login_reg.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('User is logged in');
            return HomePage();
          } else {
            print('User is not logged in');
            return SwitchLoginReg();
          }
        },
      ),
    );
  }
}
