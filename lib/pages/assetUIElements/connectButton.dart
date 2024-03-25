import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectButtonLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xff016D77),
      ),
      width: 100,
      child: Center(
        child: Row(
          children: <Widget>[
            Text('   Connect', style: GoogleFonts.poppins(color: Colors.white)),
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.person_add,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
