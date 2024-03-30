import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:univolve_app/assets/univolve2_icons.dart';
import 'package:univolve_app/pages/PagesWithin/ai_bot.dart';
import 'package:univolve_app/pages/PagesWithin/event_detail_page.dart';
import 'package:univolve_app/pages/assetUIElements/event_card_long.dart';
import 'package:univolve_app/pages/services/database_service.dart';
import 'package:univolve_app/pages/services/course.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  String nextClassInfo = "Fetching next class info...";
  List<dynamic>? courseSchedule;

  String? userName;
  List<Map<String, dynamic>> eventDetails = [];
  List<Map<String, dynamic>> trendingEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchUserNameAndSignedUpEvents();
    _fetchTrendingEvents();
    fetchUserData().then((_) {
      // Only call fetchNextClassInfo after fetchUserData completes.
      fetchNextClassInfo();
    });
  }

  Future<void> _fetchTrendingEvents() async {
    try {
      // Fetch the top 7 events ordered by 'likeCount' in descending order
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('likeCount', descending: true)
          .limit(7)
          .get();

      List<Map<String, dynamic>> fetchedTrendingEvents = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        trendingEvents = fetchedTrendingEvents;
      });
    } catch (e) {
      print("Error fetching trending events: $e");
    }
  }

  String getPhotoUrl(dynamic user) {
    // Access the user document's data as a map
    var userData = user.data() as Map<String, dynamic>;

    // Use the null-aware operator to check for 'photoUrl' and provide a default value
    return userData['photoUrl'] ??
        'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png';
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
            Map<String, dynamic> eventData =
                eventSnapshot.data() as Map<String, dynamic>;
            print("Fetched event data: $eventData"); // Log the event data
            fetchedEventDetails.add(eventData);
          } else {
            print("Event with ID $eventId not found.");
          }
        }

        // Now sort the fetched events by likeCount in descending order
        fetchedEventDetails.sort((a, b) {
          int likeCountA = a['likeCount'] ?? 0;
          int likeCountB = b['likeCount'] ?? 0;
          return likeCountB.compareTo(likeCountA); // For descending order
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

  Future<void> fetchUserData() async {
    var docRef =
        FirebaseFirestore.instance.collection('users').doc("T00702923");
    var snapshot = await docRef.get();

    var data =
        snapshot.data(); // Get the data once and store it in a local variable

    // Use ?. and ?? to provide a fallback in case of null
    if (snapshot.exists && data!.containsKey('courseSchedule') ?? false) {
      setState(() {
        courseSchedule = data?['courseSchedule'] as List<dynamic>?;
      });
    } else {
      setState(() {
        courseSchedule = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        width: 140, // Set the desired width here
        child: FloatingActionButton(
          backgroundColor: Color(0xff016D77),
          onPressed: () {
            // Navigate to the AIBot page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AIBot()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Univolve2.univolveicon, color: Colors.white),
              SizedBox(width: 8),
              // Add a text widget to display the text
              Text(
                'AdvisorAI',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                userName ?? 'Fetching name...',
                style: GoogleFonts.poppins(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'We hope you are having a great day!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 5),
              Divider(),
              SizedBox(height: 5),
              if (courseSchedule != null) buildOverviewSection(),
              // Text for following section
              Text(
                'Following Events',
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
                    print(
                        "Event data for card: $data"); // Log the data for the current card

                    // Ensure you handle null values appropriately before here
                    return Container(
                      width: 330,
                      child: EventCard(
                        imagePath: data['imagePath'] ??
                            'defaultImagePath', // Example of handling null
                        title: data['title'] ?? 'No Title',
                        time: data['time'] ?? 'No Time',
                        location: data['location'] ?? 'No Location',
                        date: data['date'] != null
                            ? formatTimestampToString(data['date'])
                            : 'No Date',
                        type: data['type'] ?? 'No Type',
                        likeCount: data['likeCount'] ?? 0,
                        documentId: data['documentId'] ?? 'No Document ID',
                        // Continue for other fields
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),

              // Another Text Widget
              Text(
                'Trending Events',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                height: 200, // Adjust based on your card size
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingEvents.length,
                  itemBuilder: (context, index) {
                    final event = trendingEvents[index];
                    return GestureDetector(
                      onTap: () {
                        // Add navigation to the event details page

                        // Navigator.push(context, MaterialPageRoute(builder: (_) {
                        //   return EventDetailsPage(
                        //     imagePath: data['imagePath'],
                        //     documentId: eventDocument[index].id,
                        //   );
                        // }));
                      },
                      child: Container(
                        width: 330,
                        child: EventCard(
                          imagePath: event['imagePath'] ?? 'defaultImagePath',
                          title: event['title'] ?? 'No Title',
                          date: event['date'] != null
                              ? formatTimestampToString(event['date'])
                              : 'No Date',
                          time: event['time'] ?? 'No Time',
                          location: event['location'] ?? 'No Location',
                          likeCount: event['likeCount'] ?? 0,
                          type: event['type'] ?? 'No Type',
                          documentId: event['documentId'] ?? 'No Document ID',
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Friend Suggestions',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 15), // Add some spacing
// Grid of friend suggestions
              Container(
                height: 380, // Set a height for the GridView container
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    var documents = snapshot.data!.docs;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 0,
                        crossAxisCount: 3, // Number of columns
                        childAspectRatio:
                            2 / 3, // Aspect ratio of each grid cell
                      ),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        var user = documents[index];
                        return GridTile(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 40, // Size of the avatar
                                backgroundImage:
                                    NetworkImage(getPhotoUrl(user)),
                              ),
                              SizedBox(height: 8),
                              Text(
                                user.get('username') ?? 'Unavailable',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '#mutualFriends',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatTimestampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    List<String> monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    // Format: "Month day, year" (e.g., "February 13, 2024")
    String formattedDate =
        "${monthNames[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}";
    return formattedDate;
  }

  Widget buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Day',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Add a SizedBox for some spacing between the text widgets
          SizedBox(height: 8.0),
          // Display the next class info
          Text(
            nextClassInfo, // Use the nextClassInfo variable here
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void fetchNextClassInfo() async {
    try {
      // Check if courseSchedule is not null.
      print(courseSchedule);
      if (courseSchedule != null) {
        // Process the course schedule to find the current or next class.
        Map<String, dynamic>? classInfo =
            CourseManager.findCurrentOrNextClass(courseSchedule);

        // Construct the info string based on the found class.
        String info;
        if (classInfo != null) {
          final courseName = classInfo['courseName'];
          final occurringTime = classInfo['occuringTime'];
          final location = classInfo['location'];
          final instructor = classInfo['instructor'];
          final status =
              classInfo['status']; // This is either 'ongoing' or 'upcoming'

          if (status == 'ongoing') {
            info =
                "Your class is currently ongoing,\n🏫 $courseName\n🧑 Professor $instructor\n🕗 $occurringTime\n📍 $location";
          } else if (status == 'upcoming') {
            info =
                "You have an upcoming class soon.\n🏫 $courseName\n🧑 Professor $instructor\n🕗 $occurringTime\n📍 $location";
          } else {
            info = "No class information available."; // Fallback message
          }
        } else {
          info =
              "No more classes today! Perfect time for a study session or a little music. Enjoy your day to the fullest! 🌸";
        }

        setState(() {
          nextClassInfo =
              info; // Update your state with the received information.
        });
      } else {
        // Handle the case where courseSchedule is null.
        setState(() {
          nextClassInfo = "No course schedule available.";
        });
      }
    } catch (e) {
      // Handle any errors that occur during fetching or setState call.
      setState(() {
        nextClassInfo = "Failed to fetch next class info.";
      });
      print(e.toString()); // Log the error.
    }
  }
}
