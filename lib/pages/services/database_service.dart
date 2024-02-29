import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> fetchUserName() async {
    final user = _auth.currentUser;
    if (user == null) return "Not signed in";

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isEmpty) return "User not found";

      final userDoc = querySnapshot.docs.first;
      final universityId = userDoc['universityId'] as String;
      final universityDoc =
          await _firestore.collection('users').doc(universityId).get();

      return universityDoc['username'] ?? "No name available";
    } catch (e) {
      return "Error fetching name";
    }
  }

  Future<String> fetchProfileImg() async {
    final user = _auth.currentUser;
    if (user == null) return "Not signed in";

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isEmpty) return "User not found";

      final userDoc = querySnapshot.docs.first;
      final universityId = userDoc['universityId'] as String;
      final universityDoc =
          await _firestore.collection('users').doc(universityId).get();

      return universityDoc['photoUrl'] ?? 'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/defaultProfilePhoto.png';
    } catch (e) {
      return "";
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) return {"error": "Not signed in"};

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isEmpty) return {"error": "User not found"};

      final userDoc = querySnapshot.docs.first.data();
      return userDoc; // This is already a Map<String, dynamic>
    } catch (e) {
      return {"error": "Error fetching user details"};
    }
  }
}
