import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:univolve_app/pages/assetUIElements/event_card_long.dart';
import 'package:google_fonts/google_fonts.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final List<EventCard> eventCards = [
    EventCard(
      imagePath: 'lib/assets/images/demobackground.png',
      title: 'Meet The Profs: Computer Science Club',
      date: 'February 13, 2024',
      time: '6:00 - 9:00',
      location: 'OM 1330',
      likeCount: 34,
      type: 'sports',
    ),
    EventCard(
      imagePath: 'lib/assets/images/demobackground.png',
      title: 'Music Jam: TRUSU',
      date: 'March 5, 2024',
      time: '7:00 - 10:00',
      location: 'The Amphitheatre',
      likeCount: 58,
      type: 'entertainment',
    ),
    EventCard(
      imagePath: 'lib/assets/images/demobackground.png',
      title: 'ABC Restaurant, McGill Road',
      date: 'Student Special',
      time: '',
      location: 'Show your ID, get 10% off meals!',
      likeCount: 22,
      type: 'advertisement',
    ),
    EventCard(
      imagePath: 'lib/assets/images/demobackground.png',
      title: 'Supply Chain Seminar',
      date: 'February 13, 2024',
      time: '6:00 - 9:00',
      location: 'IB 1330',
      likeCount: 13,
      type: 'academic',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 12.0),
              child: Text(
                'Trending Events',
                style: GoogleFonts.poppins(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              height: 208.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: eventCards.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 300.0, // Set your desired width here
                    child: eventCards[index],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 12.0),
              child: Text(
                'Explore More',
                style: GoogleFonts.poppins(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: eventCards.length,
                itemBuilder: (context, index) {
                  return eventCards[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
