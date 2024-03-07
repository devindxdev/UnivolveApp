import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:univolve_app/pages/PagesWithin/ai_bot.dart';
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
    print(Timestamp.fromDate(DateTime(2024, 2, 13)));
    _fetchInitialData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchMoreData();
      }
    });
  }

  Future<void> _fetchInitialData() async {
    var query = FirebaseFirestore.instance
        .collection('events')
        .orderBy('date') // Assuming there is a 'date' field to sort by
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
      appBar: AppBar(
        title: Text('Events', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            onPressed: () {
              // Add navigation to new page
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return ChatBot();
              }));
            },
            icon: Icon(Icons.help_outline),
          ),
        ],
      ),
      body: eventDocuments.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                var data = eventDocuments[index].data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    // Add navigation to the event details page
                  },
                  child: EventCard(
                    imagePath: data['imagePath'],
                    title: data['title'],
                    date: formatTimestampToString(data['date']),
                    time: data['time'],
                    location: data['location'],
                    likeCount: data['likeCount'] ?? 0,
                    type: data['type'],
                    documentId: eventDocuments[index].id,
                  ),
                );
              },
            ),
    );
  }
}
