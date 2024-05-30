import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterScreen({super.key, required this.showLoginPage});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController universityIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _termsAccepted = true;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  //dispose of the controllers
  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    universityIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  final RegExp passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,12}$',
  );

  //signup function
  Future signUp() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must accept the terms and conditions to register.'),
          backgroundColor: Colors.grey[900],
        ),
      );
      return;
    }

    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        universityIdController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.grey[900],
        ),
      );
      return;
    }

    if (!passwordRegExp.hasMatch(passwordController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be 8-12 characters long and include uppercase, lowercase, numbers, and special characters.'),
          backgroundColor: Colors.grey[900],
        ),
      );
      return;
    }

    if (passwordController.text.trim() == confirmPasswordController.text.trim()) {
      final String documentId = universityIdController.text.trim();
      final doc = await FirebaseFirestore.instance.collection('users').doc(documentId).get();

      if (doc.exists) {
        String existingEmail = doc.data()?['email'] ?? 'No email available';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student ID is already in use by $existingEmail. Please either login using that or contact support.'),
            backgroundColor: Colors.grey[900],
          ),
        );
        return;
      }

      try {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await addUserdetails();
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred. Please try again.'),
            backgroundColor: Colors.grey[900],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords don't match"),
          backgroundColor: Colors.grey[900],
        ),
      );
    }
  }

  //add user details to the database
  Future<void> addUserdetails() async {
    String documentId = universityIdController.text.trim();
    try {
      await FirebaseFirestore.instance.collection('users').doc(documentId).set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'universityId': universityIdController.text.trim(),
        'photoUrl': 'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png',
        'bio': "No bio provided yet..",
        'currentCourses': {},
        'interests': "",
        'likedEvents': [],
        'notificationEvents': [],
        'program': "Not Chosen Yet",
        'socialMediaHandles': {
          'Github': "",
          'Instagram': "",
          'LinkedIn': "",
          'Website': "",
        },
        'friends': [],
        'friendsCount': 0,
        'truClub': '',
        "positionInClub": "Not a member",
      });
      print("User details added successfully");
    } catch (e) {
      print("Error adding user details: $e");
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Terms and Conditions'),
          content: SingleChildScrollView(
            child: Text('Your terms and conditions go here...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Decline'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _termsAccepted = true;
                });
                Navigator.of(context).pop();
              },
              child: Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Hello! Register to get started',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 48.0),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: universityIdController,
                decoration: InputDecoration(
                  labelText: 'University ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: confirmPasswordController,
                obscureText: !_confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("By registering, you accepting our "),
                  GestureDetector(
                    onTap: _showTermsDialog,
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.0),
              GestureDetector(
                onTap: _termsAccepted ? signUp : null,
                child: Container(
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _termsAccepted ? Color(0xff016D77) : Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.showLoginPage,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? Login Now',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
