import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:univolve_app/assets/univolve2_icons.dart';

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
  late TextEditingController _positionController;
  late TextEditingController _truClubController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  late TextEditingController _websiteController;
  late TextEditingController _instagramController;

  List<String> programOptions = [
    'Not Choosen Yet',
    'Diploma Computer Science',
    'Bachelor of Computer Science'
  ];

  List<String> availableCourses = [
    'Choose Course',
    "COMP2130 - Introduction to Computer Systems",
    "COMP2160 - Mobile Application Development 1",
    "COMP2210 - Programming Methods",
    "COMP2230 - Data Structure, Algorithm Analysis, and Program Design",
    "COMP2680 - Web Site Design and Development",
    "COMP2920 - Software Architecture Design",
    "COMP3050 - Algorithm Design and Analysis",
    "COMP3130 - Formal Languages, Automata and Computability",
    "COMP3260 - Computer Network Security",
    "COMP3270 - Computer Network",
    "COMP3410 - Operating Systems",
    "COMP3450 - Human-Computer Interaction Design",
    "COMP3520 - Software Engineering",
    "COMP3540 - Advanced Web Design and Programming",
  ];

  List<String> currentCourses = [];

  List<String> clubPositions = [
    'Not a member',
    'President',
    'Vice President',
    'Member'
  ]; // List of club positions

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
    _positionController =
        TextEditingController(text: widget.userData['positionInClub'] ?? '');
    _truClubController =
        TextEditingController(text: widget.userData['truClub'] ?? '');
    _linkedinController = TextEditingController(
        text: widget.userData['socialMediaHandles']['LinkedIn']);
    _githubController = TextEditingController(
        text: widget.userData['socialMediaHandles']['Github']);
    _websiteController = TextEditingController(
        text: widget.userData['socialMediaHandles']['Website']);
    _instagramController = TextEditingController(
        text: widget.userData['socialMediaHandles']['Instagram']);
    fetchProgramOptions();
    fetchClubPositions();
    fetchAvailableCourses();
    fetchCurrentCourses(widget.userData['universityId']);
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
    _positionController.dispose();
    _truClubController.dispose();
    super.dispose();
  }

  Future<void> fetchProgramOptions() async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('assets')
        .doc('availablePrograms')
        .get();
    print(snapshot.data()!);
    List<dynamic> programs = snapshot['programs'];
    setState(() {
      programOptions = List<String>.from(programs);
      if (!programOptions.contains(_programController.text)) {
        _programController.text = programOptions.first; // or 'Not Chosen Yet' if it's always present
      }
    });
  } catch (e) {
    print('Error fetching program options: $e');
    // Set a default list if fetch fails
    setState(() {
      programOptions = ['Not Chosen Yet'];
    });
  }
}

  Future<void> fetchClubPositions() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('assets')
        .doc('clubPositions')
        .get();
    List<dynamic> positions = snapshot['positions'];
    setState(() {
      clubPositions = List<String>.from(positions);
    });
  }

  Future<void> fetchAvailableCourses() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('assets')
        .doc('availableCourses')
        .get();
    Map<String, dynamic> courses = snapshot['courseList'];
    setState(() {
      availableCourses = courses.entries
          .map((entry) => "${entry.key} : ${entry.value}")
          .toList();
    });
  }

  Future<void> fetchCurrentCourses(String userDocId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .get();
    Map<String, dynamic> courses = snapshot['currentCourses'];
    setState(() {
      currentCourses = courses.entries
          .map((entry) => "${entry.key} : ${entry.value}")
          .toList();
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userDocId = widget.userData['universityId'];

      if (userDocId == null || userDocId.isEmpty) {
        print('Invalid document ID');
        return;
      }

      // Convert currentCourses back into a map for Firestore
      Map<String, String> coursesMap = {};
      for (var course in currentCourses) {
        // Assuming course is in the format "COMP2130 : Introduction to Computer Systems"
        var parts = course.split(
            " : "); // Split by " : " to get [COMP2130, Introduction to Computer Systems]
        if (parts.length == 2) {
          coursesMap[parts[0]] = parts[1];
        }
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
          'currentCourses': coursesMap,
          'truClub': _truClubController.text,
          'positionInClub': _positionController.text,
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
// Inside your _saveProfile function, after successfully updating the profile
        Navigator.pop(context, true); // 'true' indicates changes were made
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

  List<Widget> _buildCourseSelections() {
    List<Widget> courseWidgets = [];
    for (int i = 0; i < currentCourses.length; i++) {
      courseWidgets.add(
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: currentCourses[i],
                onChanged: (newValue) {
                  setState(() {
                    currentCourses[i] = newValue!;
                  });
                },
                items: availableCourses.map((course) {
                  return DropdownMenuItem<String>(
                    value: course,
                    child: Text(
                      course.length > 24
                          ? course.substring(0, 24) + '...'
                          : course,
                      style: GoogleFonts.poppins(fontSize: 12.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Restrict to one line
                    ),
                  );
                }).toList(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.remove_circle, color: Color(0xff016D77)),
              onPressed: () {
                setState(() {
                  currentCourses.removeAt(i);
                });
              },
            ),
          ],
        ),
      );
    }
    courseWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.add_circle, color: Color(0xff016D77)),
            onPressed: () {
              setState(() {
                currentCourses.add(availableCourses[0]);
              });
            },
          ),
          Text('Add Course',
              style: GoogleFonts.poppins(fontSize: 12.0)), // Small text size
        ],
      ),
    );
    return courseWidgets;
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
                  child: Text('Save Profile',
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
              color: Color(
                0xffF2F2F2,
              ),
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
          Row(
            children: [
              Container(
                width: 90,
                child: Text(
                  'Your Name',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 3),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    style: GoogleFonts.poppins(fontSize: 14.0),
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Your name cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 85,
                child: Text(
                  'Program',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: DropdownButtonFormField<String>(
  decoration: InputDecoration(
    border: InputBorder.none,
    hintText: 'Select Program',
    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
  ),
  value: programOptions.contains(_programController.text) 
      ? _programController.text 
      : (programOptions.isNotEmpty ? programOptions.first : null),
  onChanged: (String? value) {
    setState(() {
      _programController.text = value ?? '';
    });
  },
  items: programOptions.map((String option) {
    return DropdownMenuItem<String>(
      value: option,
      child: Text(option, style: GoogleFonts.poppins(fontSize: 14.0)),
    );
  }).toList(),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please select a program';
    }
    return null;
  },
)
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 85,
                child: Text(
                  'Courses',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: _buildCourseSelections(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 90,
                child: Text(
                  'Bio',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 3),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    style: GoogleFonts.poppins(fontSize: 14.0),
                    controller: _bioController,
                    decoration: InputDecoration(
                      hintText: 'Enter your bio',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bio cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 90,
                child: Text(
                  'Interests',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 3),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    style: GoogleFonts.poppins(fontSize: 14.0),
                    controller: _interestsController,
                    decoration: InputDecoration(
                      hintText: 'Enter your interests',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    maxLines: 2,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Interests cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // New UI for TRU Club
          _buildTextInputRow('TRU Club', _truClubController),

          SizedBox(height: 16),
          _buildDropdownRow(
              'Position in Club', _positionController, clubPositions),

          SizedBox(height: 16),
          Divider(),
          Text(
            'Social Media Handles ',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              color: Color(0xff016D77),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Univolve2.linkedin, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    controller: _linkedinController,
                    decoration: InputDecoration(
                      hintText: 'LinkedIn (Optional)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Univolve2.github, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    controller: _githubController,
                    decoration: InputDecoration(
                      hintText: 'Github (Optional)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.link_sharp, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    controller: _websiteController,
                    decoration: InputDecoration(
                      hintText: 'Website (Optional)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Univolve2.instagram, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextFormField(
                    controller: _instagramController,
                    decoration: InputDecoration(
                      hintText: 'Instagram (Optional)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.0),
          GestureDetector(
            onTap: _saveProfile,
            child: Container(
              child: Text(
                'Update Profile',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

  // Function to build a row with a text input field
  Widget _buildTextInputRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Container(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 14.0, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(width: 3),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextFormField(
              style: GoogleFonts.poppins(fontSize: 14.0),
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter the $label you are part of',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
              maxLines: 2,
              keyboardType: TextInputType.multiline,
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return '$label cannot be empty';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  // Function to build a row with a dropdown field
  Widget _buildDropdownRow(
      String label, TextEditingController controller, List<String> options) {
    return Row(
      children: [
        Container(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 14.0, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(width: 3),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Select $label',
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
              value: controller.text,
              onChanged: (String? value) {
                setState(() {
                  controller.text = value ?? '';
                });
              },
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: GoogleFonts.poppins(fontSize: 14.0),
                  ),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a $label';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
