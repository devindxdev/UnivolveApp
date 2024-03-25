import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:univolve_app/pages/PagesWithin/qr_scanner.dart';
import 'package:univolve_app/pages/PagesWithin/view_profile.dart';
import 'package:univolve_app/pages/assetUIElements/connectButton.dart';

class SearchUserPage extends StatefulWidget {
  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  String searchQuery = "";

  String getPhotoUrl(dynamic user) {
    // Access the user document's data as a map
    var userData = user.data() as Map<String, dynamic>;

    // Use the null-aware operator to check for 'photoUrl' and provide a default value
    return userData['photoUrl'] ??
        'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),
        //add camera widget icon in action so that when I tap it opens QR scanner
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerPage()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Search by name',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: (searchQuery.isEmpty)
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .limit(10)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('users')
                      .where('username', isGreaterThanOrEqualTo: searchQuery)
                      .where('username',
                          isLessThanOrEqualTo: searchQuery + '\uf8ff')
                      .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                var documents = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    var user = documents[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(getPhotoUrl(user)),
                      ),
                      title: Text(user.get('username'),
                          style: GoogleFonts.poppins(fontSize: 20)),
                      trailing: ConnectButtonLarge(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProfilePage(
                                user: user.data() as Map<String, dynamic>),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
