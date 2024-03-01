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
  Color getTypeColor(String type) {
    // Method that returns a color based on the event type.
    switch (type.toLowerCase()) {
      case 'sports':
        return Color(0xFFB38F71);
      case 'academic':
        return Color(0xFF9e2a2b);
      case 'entertainment':
        return Color(0xFF3a5a40);
      case 'advertisement':
        return Color(0xFFee6c4d);
      default:
        return Colors.grey; // Default color if type doesn't match.
    }
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = getTypeColor(widget.type);
    return Card(
      color: cardColor,
      elevation: 0.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: 'eventImage-${widget.documentId}',
            child: Image.network(
              widget.imagePath,
              height: 100.0,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${widget.date} · ${widget.time}",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 12.0)),
                        SizedBox(height: 5.0),
                        Text(widget.location,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 12.0)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
        ],
      ),
    );
  }
}
