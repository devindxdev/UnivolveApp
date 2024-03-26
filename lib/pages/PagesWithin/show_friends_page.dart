import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:univolve_app/pages/PagesWithin/view_profile.dart';

class ShowFriendsPage extends StatefulWidget {
  final String universityId;

  const ShowFriendsPage({Key? key, required this.universityId})
      : super(key: key);

  @override
  _ShowFriendsPageState createState() => _ShowFriendsPageState();
}

class _ShowFriendsPageState extends State<ShowFriendsPage> {
  late Future<List<Map<String, dynamic>>> friendsList;

  @override
  void initState() {
    super.initState();
    friendsList = fetchFriends();
  }

  Future<List<Map<String, dynamic>>> fetchFriends() async {
    // Fetch the user document first to get the friends list
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.universityId)
        .get();
    List<dynamic> friendsIds = userDoc['friends'];

    List<Map<String, dynamic>> friendsDetails = [];

    // Fetch each friend's details
    for (String friendId in friendsIds) {
      DocumentSnapshot friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();
      Map<String, dynamic> friendData =
          friendDoc.data() as Map<String, dynamic>;
      friendsDetails.add(friendData);
    }

    return friendsDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends', style: GoogleFonts.poppins()),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: friendsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching friends'));
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text('No friends found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var friend = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend['photoUrl'] ??
                      'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png'),
                ),
                title: Text(friend['username'] ?? 'User',
                    style: GoogleFonts.poppins()),
                onTap: () {
                  // Navigate to friend's profile page, adjust as necessary
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ViewProfilePage(user: friend)));
                },
                trailing: Container(
                  width: 90,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                      (friend['friendsCount'] != null)
                          ? friend['friendsCount'] + ' friends'
                          : '0 friends',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
