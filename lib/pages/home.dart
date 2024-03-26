import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'event_card_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName;
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _fetchUserNameAndEvents();
  }

  Future<void> _fetchUserNameAndEvents() async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc('your_user_id').get();
    QuerySnapshot eventSnapshot = await _firestore
        .collection('events')
        .orderBy('date', descending: true)
        .get();

    setState(() {
      userName = (userSnapshot.data() as Map<String, dynamic>)['name'];
      events = eventSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
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
              Text(
                'Following Events 🔥',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              // Event cards
              for (var event in events)
                EventCardWidget(
                  title: event['title'],
                  date: event['date'],
                  location: event['location'],
                ),
              SizedBox(height: 24),
              Text(
                'Friend Suggestions',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventCardWidget extends StatelessWidget {
  final String title;
  final String date;
  final String location;

  const EventCardWidget({
    Key? key,
    required this.title,
    required this.date,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('$date at $location'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // Implement navigation to event detail
        },
      ),
    );
  }
}
