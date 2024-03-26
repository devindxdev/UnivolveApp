import 'dart:ui'; // Import this to use ImageFilter for blur.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:univolve_app/pages/PagesWithin/event_detail_page.dart';

class EventCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String date;
  final String time;
  final String location;
  final int likeCount;
  final String type;
  final String documentId;

  EventCard({
    required this.imagePath,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.likeCount,
    required this.type,
    required this.documentId,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          // Background Image
          Hero(
            tag: 'eventImage-${widget.documentId}',
            child: Image.network(
              widget.imagePath,
              height: 200.0, // Adjusted height for better visual
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Frosted Glass effect only at the bottom

          // Text content positioned to align with the frosted glass effect
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 72.0,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 20), // Integrated padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${widget.date} · ${widget.time}",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 12.0)),
                              Text(widget.location,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 12.0)),
                            ],
                          ),
                          Row(
                            children: [
                              Text(widget.likeCount.toString(),
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(width: 4.0),
                              Icon(Icons.favorite,
                                  color: Color.fromARGB(255, 254, 82, 69),
                                  size: 30.0),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
