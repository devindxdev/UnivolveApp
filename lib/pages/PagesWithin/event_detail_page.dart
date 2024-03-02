import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class EventDetailsPage extends StatefulWidget {
  final String documentId;
  final String imagePath;

  EventDetailsPage({
    required this.documentId,
    required this.imagePath,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

bool _hasLiked = false;
final String _userId =
    FirebaseAuth.instance.currentUser!.uid; // Assuming user is logged in

class _EventDetailsPageState extends State<EventDetailsPage> {
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

  String getStartTime(String time) {
    List<String> parts = time.split(" - ");
    return parts[0]; // Return anything before "-"
  }

  String getEndTime(String time) {
    List<String> parts = time.split(" - ");
    return parts.length > 1 ? parts[1] : "TBD"; // Return anything after "-"
  }

  @override
  void initState() {
    super.initState();
    checkIfUserHasLikedEvent();
  }

  void checkIfUserHasLikedEvent() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();
    List likedEvents = userDoc['likedEvents'];
    setState(() {
      _hasLiked = likedEvents.contains(widget.documentId);
    });
  }

  void toggleLikeEvent() {
    if (_hasLiked) {
      // Unliking the event
      FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'likedEvents': FieldValue.arrayRemove([widget.documentId])
      });
      FirebaseFirestore.instance
          .collection('events')
          .doc(widget.documentId)
          .update({
        'likedBy': FieldValue.arrayRemove([_userId]),
        'likeCount': FieldValue.increment(-1)
      });
    } else {
      // Liking the event
      FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'likedEvents': FieldValue.arrayUnion([widget.documentId])
      });
      FirebaseFirestore.instance
          .collection('events')
          .doc(widget.documentId)
          .update({
        'likedBy': FieldValue.arrayUnion([_userId]),
        'likeCount': FieldValue.increment(1)
      });
    }
    setState(() {
      _hasLiked = !_hasLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details',
            style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.documentId)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }
          if (!snapshot.hasData) {
            return Center(child: Text("Event not found"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String title = data['title'];
          String date = formatTimestampToString(data['date']);
          // Split the time into start and end time
          String startTime = getStartTime(data['time']);
          String endTime = getEndTime(data['time']);
          String location = data['location'];
          String description =
              data['description'] ?? 'No description available';
          int likeCount = data['likeCount'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(alignment: Alignment.bottomCenter, children: [
                  Hero(
                    tag: 'eventImage-${widget.documentId}',
                    child: Image.network(
                      widget.imagePath,
                      height: 200.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      //border radius for top left and top right
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 30,
                    ),
                  ),
                ]),
                Padding(
                  padding: EdgeInsets.fromLTRB(26, 0, 26, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff016D77)),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '    $likeCount',
                                style: GoogleFonts.poppins(fontSize: 26),
                              ),
                              GestureDetector(
                                onTap: toggleLikeEvent,
                                child: Center(
                                  child: Icon(
                                    Icons.favorite,
                                    color: _hasLiked ? Colors.red : Colors.grey,
                                    size: 34,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 23,
                          ),
                          SizedBox(width: 8),
                          Text(
                            location,
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            date,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'About Event',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xffEBEEF5).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Color(0xffEBEEF5), width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            EventTimeInfoBox(label: 'START', time: startTime),
                            EventTimeInfoBox(label: 'END', time: endTime),
                          ],
                        ),
                      ),
                      SizedBox(height: 200),
                      SwipeableButtonView(
                        onFinish: () {},
                        onWaitingProcess: () {},
                        activeColor: const Color(0xff016D77),
                        buttonWidget: const Icon(Icons.notification_add,
                            color: Color(0xff016D77), size: 30),
                        buttonText: "Notify Me for this Event",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EventTimeInfoBox extends StatelessWidget {
  final String label;
  final String time;

  const EventTimeInfoBox({
    Key? key,
    required this.label,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
