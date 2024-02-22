import 'package:flutter/material.dart';
import 'package:univolve_app/pages/login_page.dart';
import 'package:univolve_app/pages/register_page.dart';

class SwitchLoginReg extends StatefulWidget {
  @override
  _SwitchLoginRegState createState() => _SwitchLoginRegState();
}

class _SwitchLoginRegState extends State<SwitchLoginReg> {
  bool _showLogin = true;

  void togglePage() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginScreen(showRegisterPage: togglePage);
    } else {
      return RegisterScreen(showLoginPage: togglePage);
    }
  }
}
