import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:univolve_app/pages/assetUIElements/event_card_long.dart';
import 'package:univolve_app/pages/services/database_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  String? userName;
  List<Map<String, dynamic>> eventDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchUserNameAndSignedUpEvents();
  }

  Future<void> _fetchUserNameAndSignedUpEvents() async {
    try {
      Map<String, dynamic>? userDetails = await _userService.fetchUserDetails();
      if (userDetails != null) {
        setState(() {
          userName = userDetails['username'];
        });

        List<dynamic> notificationEvents =
            userDetails['notificationEvents'] ?? [];

        List<Map<String, dynamic>> fetchedEventDetails = [];
        for (String eventId in notificationEvents) {
          DocumentSnapshot eventSnapshot =
              await _firestore.collection('events').doc(eventId).get();
          if (eventSnapshot.exists) {
            fetchedEventDetails
                .add(eventSnapshot.data() as Map<String, dynamic>);
          } else {
            print("Event with ID $eventId not found.");
          }
        }

        // Sort the events by date in ascending order
        fetchedEventDetails.sort((a, b) {
          DateTime dateA = (a['date'] as Timestamp).toDate();
          DateTime dateB = (b['date'] as Timestamp).toDate();
          return dateA.compareTo(dateB);
        });

        setState(() {
          eventDetails = fetchedEventDetails;
        });
      } else {
        print("User details not found.");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Welcome message and user name display
              Text(
                'Welcome back,',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                userName ?? 'Fetching name...',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),

              // Text for Trending Events
              Text(
                'Trending Events',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Horizontal list view for event cards
              Container(
                height: 200, // Adjust the height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: eventDetails.length,
                  itemBuilder: (context, index) {
                    final data = eventDetails[index];
                    return EventCard(
                      imagePath: data['imagePath'],
                      title: data['title'],
                      date: formatTimestampToString(data['date']),
                      time: data['time'],
                      location: data['location'],
                      likeCount: (data['likeCount'] ?? 0).toInt(),
                      type: data['type'],
                      documentId: data[
                          'id'], // Assuming 'id' is a field in your event documents
                    );
                  },
                ),
              ),
              SizedBox(height: 24),

              // Another Text Widget
              Text(
                'Another Section',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Any other widgets you want to include
            ],
          ),
        ),
      ),
    );
  }

  String formatTimestampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    // Your existing format logic
    return '';
  }
}
