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
  final TextEditingController confirmPasswordController =
      TextEditingController();

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

  //signup function
  Future signUp() async {
    // Check if any of the fields are empty
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        universityIdController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      // Display a SnackBar if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.grey[900],
        ),
      );
      return; // Stop the function execution if any field is empty
    }

    // Proceed if passwords match and fields are not empty
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      final String documentId = universityIdController.text.trim();
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(documentId)
          .get();

      // Check if a user with the same student ID already exists
      if (doc.exists) {
        // Fetch the email associated with the existing student ID
        String existingEmail = doc.data()?['email'] ?? 'No email available';

        // Display a SnackBar if the student ID is already in use, including the associated email
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Student ID is already in use by $existingEmail. Please either login using that or contact support.'),
            backgroundColor: Colors.grey[900],
          ),
        );
        return; // Stop the function execution if the student ID is already in use
      }

      try {
        // If the student ID is unique, proceed with user registration
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // After successful registration, add user details to Firestore
        await addUserdetails();

        // Optionally, handle the userCredential as needed, e.g., storing additional user info
      } on FirebaseAuthException catch (e) {
        // Handle Firebase Auth exceptions, e.g., email already in use
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred. Please try again.'),
            backgroundColor: Colors.grey[900],
          ),
        );
      }
    } else {
      // Display a SnackBar if passwords don't match
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords don't match"),
          backgroundColor: Colors.grey[900],
        ),
      );
    }
  }

  //add user details to the database to
  Future<void> addUserdetails() async {
    String documentId = universityIdController.text.trim();

    try {
      await FirebaseFirestore.instance.collection('users').doc(documentId).set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'universityId': universityIdController.text.trim(),
      });
      print("User details added successfully");
    } catch (e) {
      print("Error adding user details: $e");
    }
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
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24.0),
              GestureDetector(
                onTap: signUp,
                child: Container(
                  child: Text('Register',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xff016D77),
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
                      Text('Already have an account? Login Now',
                          style: TextStyle(color: Colors.black)),
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
