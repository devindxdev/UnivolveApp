import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    'Not Choosen Yet',
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
    // TextEditingController(text: widget.userData['program']);
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

  // Method to upload image
  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String userDocId = widget.userData['universityId'];

      if (userDocId == null || userDocId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid user ID'),
          duration: Duration(seconds: 2),
        ));
        return;
      }

      try {
        // Construct the file path in Firebase Storage
        String filePath = 'profilePictures/$userDocId';
        Reference ref = FirebaseStorage.instance.ref().child(filePath);

        // Upload or replace the file at the specified path
        await ref.putFile(imageFile);

        // Once the upload is complete, get the download URL
        final imageUrl = await ref.getDownloadURL();

        // Check if it's an update or a new upload by examining widget.userData['photoUrl']
        bool isUpdate = widget.userData['photoUrl'] != null;

        // Update Firestore document with the new image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDocId)
            .update({
          'photoUrl': imageUrl,
        });

        // Update local userData map to reflect the new photoUrl
        setState(() {
          widget.userData['photoUrl'] = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isUpdate
              ? 'Image updated successfully!'
              : 'Image uploaded successfully!'),
          duration: Duration(seconds: 2),
        ));
      } catch (error) {
        print('Error uploading image: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload image. Please try again.'),
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      print('No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
            style: GoogleFonts.poppins(color: Colors.black)),
        actions: [
          GestureDetector(
            onTap: _saveProfile,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Update Profile',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600)),
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xff016D77),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: EdgeInsets.all(16.0), children: <Widget>[
          SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xffEDF6F9),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(widget
                              .userData['photoUrl'] ??
                          'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png'),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: uploadImage,
                      child: Container(
                        width: 170,
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Change Image',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
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
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(width: 8),
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
            value: _programController.text,
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
          Row(
            children: [
              Icon(Icons.link, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _linkedinController,
                  decoration: InputDecoration(labelText: 'LinkedIn (Optional)'),
                ),
              ),
            ],
          ),
          Row(children: [
            Icon(Icons.link, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _githubController,
                decoration: InputDecoration(labelText: 'Github (Optional)'),
              ),
            ),
          ]),
          Row(children: [
            Icon(Icons.link, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(labelText: 'Website (Optional)'),
              ),
            ),
          ]),
          Row(children: [
            Icon(Icons.link, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _instagramController,
                decoration: InputDecoration(labelText: 'Instagram (Optional)'),
              ),
            ),
          ]),
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
        ]),
      ),
    );
  }
}
