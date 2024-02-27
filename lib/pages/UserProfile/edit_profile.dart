import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfilePage({required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bioController;
  late TextEditingController _interestsController;
  late TextEditingController _usernameController;
  late TextEditingController _programController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  late TextEditingController _websiteController;
  late TextEditingController _instagramController;

  List<String> programOptions = [
    'Diploma Computer Science',
    'Bachelor of Computer Science'
  ];

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.userData['bio']);
    _interestsController =
        TextEditingController(text: widget.userData['interests']);
    _usernameController =
        TextEditingController(text: widget.userData['username']);
    _programController =
        TextEditingController(text: widget.userData['program']);
    _linkedinController = TextEditingController(
        text: widget.userData['socialMediaHandles']['LinkedIn']);
    _githubController = TextEditingController(
        text: widget.userData['socialMediaHandles']['Github']);
    _websiteController = TextEditingController(
        text: widget.userData['socialMediaHandles']['Website']);
    _instagramController = TextEditingController(
        text: widget.userData['socialMediaHandles']['Instagram']);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _interestsController.dispose();
    _usernameController.dispose();
    _programController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userDocId = widget.userData['universityId'];

      if (userDocId == null || userDocId.isEmpty) {
        print('Invalid document ID');
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDocId)
            .update({
          'bio': _bioController.text,
          'interests': _interestsController.text,
          'username': _usernameController.text,
          'program': _programController.text,
          'socialMediaHandles': {
            'LinkedIn': _linkedinController.text,
            'Github': _githubController.text,
            'Website': _websiteController.text,
            'Instagram': _instagramController.text,
          },
        });
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
        ));
        Navigator.pop(context);
      } catch (error) {
        print('Error updating profile: $error');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
            style: GoogleFonts.poppins(color: Colors.black)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              style: GoogleFonts.poppins(),
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return 'Username cannot be empty';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Program',
              ),
              value: null,
              onChanged: (String? value) {
                setState(() {
                  _programController.text = value ?? '';
                });
              },
              items: programOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option, style: GoogleFonts.poppins()),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a program';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _bioController,
              // Your TextEditingController
              decoration: InputDecoration(
                labelText: 'Bio',
              ),
              style: GoogleFonts.poppins(),

              maxLines: 5, // Allows for multiple lines
              keyboardType: TextInputType
                  .multiline, // Sets the keyboard for multiline input
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bio cannot be empty';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _interestsController,
              decoration: InputDecoration(labelText: 'Interests'),
              style: GoogleFonts.poppins(),
              maxLines: 2, // Allows for multiple lines
              keyboardType: TextInputType.multiline, //
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return 'Interests cannot be empty';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _linkedinController,
              decoration: InputDecoration(labelText: 'LinkedIn (Optional)'),
            ),
            TextFormField(
              controller: _githubController,
              decoration: InputDecoration(labelText: 'Github (Optional)'),
            ),
            TextFormField(
              controller: _websiteController,
              decoration: InputDecoration(labelText: 'Website (Optional)'),
            ),
            TextFormField(
              controller: _instagramController,
              decoration: InputDecoration(labelText: 'Instagram (Optional)'),
            ),
            SizedBox(height: 24.0),
            GestureDetector(
              onTap: _saveProfile,
              child: Container(
                child: Text('Update Profile',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600)),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xff016D77),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
