import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:univolve_app/pages/PagesWithin/ai_bot.dart';
import 'package:univolve_app/pages/PagesWithin/chat_page.dart';
import 'package:univolve_app/pages/PagesWithin/event_detail_page.dart';
import 'package:univolve_app/pages/assetUIElements/event_card_long.dart'; // Make sure the path matches your EventCard widget

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> eventDocuments = [];
  bool isMoreDataAvailable = true;
  DocumentSnapshot? lastDocument;
  final int pageSize = 10;

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

  @override
  void initState() {
    super.initState();
    // uploadEventsFromJson();
    _fetchInitialData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchMoreData();
      }
    });
  }

  Future<String> loadJsonData(String path) async {
    return await rootBundle.loadString(path);
  }

//push events to firestore
  Future<void> pushEventsToFirestore(List eventsList) async {
    final CollectionReference eventsCollection =
        FirebaseFirestore.instance.collection('events');

    for (var eventJson in eventsList) {
      // Attempt to parse the "date" field to DateTime
      DateTime? parsedDate;
      try {
        String dateString = eventJson["date"];
        // Adjust the parsing logic based on your actual date format
        // Here, it's assumed your date format might include timezone information
        int utcIndex = dateString.indexOf(" UTC");
        if (utcIndex != -1) {
          String toParse =
              dateString.substring(0, utcIndex).replaceAll(" at ", " ");
          parsedDate = DateTime.parse(toParse);
        }
      } catch (e) {
        print("Error parsing date: $e");
        // Use current time as fallback
        parsedDate = DateTime.now();
      }

      Map<String, dynamic> eventMap = {
        "title": eventJson["title"],
        "date": parsedDate, // Using parsed DateTime object
        "description": eventJson["description"],
        "imagePath": eventJson["imagePath"],
        "likeCount": eventJson["likeCount"],
        "likedBy": eventJson["likedBy"],
        "location": eventJson["location"],
        "notifyUsers": eventJson["notifyUsers"],
        "time": eventJson["time"],
        "type": eventJson["type"] ?? "Unknown" // Default type if null
      };

      // Add the event to Firestore
      await eventsCollection.add(eventMap).then((docRef) {
        print('Document added with ID: ${docRef.id}');
      }).catchError((error) {
        print('Error adding document: $error');
      });
    }
  }

  void uploadEventsFromJson() async {
    // Load and decode JSON data from file
    String jsonString = await loadJsonData('lib/data/events.json');
    List<dynamic> eventsList = json.decode(jsonString);

    // Upload to Firestore
    await pushEventsToFirestore(eventsList).then((_) {
      print('All events have been successfully uploaded to Firestore.');
    }).catchError((error) {
      print("Error uploading events: $error");
    });
  }

  Future<void> _fetchInitialData() async {
    var query = FirebaseFirestore.instance
        .collection('events')
        .orderBy('date')
        .limit(pageSize);

    var querySnapshot = await query.get();
    var documents = querySnapshot.docs;

    if (documents.isNotEmpty) {
      setState(() {
        lastDocument = documents.last;
        eventDocuments = documents;
        isMoreDataAvailable = documents.length == pageSize;
      });
    }
  }

  Future<void> _fetchMoreData() async {
    if (!isMoreDataAvailable) return;

    var query = FirebaseFirestore.instance
        .collection('events')
        .orderBy('date')
        .startAfterDocument(lastDocument!)
        .limit(pageSize);

    var querySnapshot = await query.get();
    var documents = querySnapshot.docs;

    if (documents.isNotEmpty) {
      setState(() {
        lastDocument = documents.last;
        eventDocuments.addAll(documents);
        isMoreDataAvailable = documents.length == pageSize;
      });
    }
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Events', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () {
              // Add navigation to new page
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return ChatPage();
              }));
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xff016D77), // Background color
                borderRadius: BorderRadius.circular(20.0), // Rounded corners
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // To align children in the center
                children: [
                  Text(
                    'Ask AI about Events',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white, // Text color
                    ),
                  ),
                  SizedBox(width: 5), // Adjust spacing between text and icon
                  Icon(
                    Icons.android,
                    color: Colors.white, // Icon color
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: eventDocuments.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: eventDocuments.length +
                    1, // Add one for the loading indicator at the bottom
                itemBuilder: (context, index) {
                  if (index == eventDocuments.length) {
                    // Return loading indicator at the bottom
                    return isMoreDataAvailable
                        ? Center(child: CircularProgressIndicator())
                        : Container();
                  }
                  var data =
                      eventDocuments[index].data() as Map<String, dynamic>;
                  print(data);
                  return GestureDetector(
                    onTap: () {
                      // Add navigation to the event details page
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return EventDetailsPage(
                          imagePath: data['imagePath'],
                          documentId: eventDocuments[index].id,
                        );
                      }));
                    },
                    child: EventCard(
                      imagePath: data['imagePath'],
                      title: data['title'],
                      date: formatTimestampToString(data['date']),
                      time: data['time'],
                      location: data['location'],
                      likeCount: (data['likeCount'] ?? 0).toInt(),
                      type: data['type'],
                      documentId: eventDocuments[index].id,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
