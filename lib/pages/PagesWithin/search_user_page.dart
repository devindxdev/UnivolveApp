import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchUserPage extends StatefulWidget {
  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  String searchQuery = "";

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
              // Implement QR scanner logic here
              
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value
                      .trim()
                      .toLowerCase(); // Assuming usernames are stored in lowercase
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
                        // backgroundImage: NetworkImage(user.get('photoUrl') ??
                        //     'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png'),
                        backgroundImage: NetworkImage(
                            'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png'),
                      ),
                      title: Text(user.get('username')),
                      trailing: IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: () {
                          // Implement add connection logic here
                        },
                      ),
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
