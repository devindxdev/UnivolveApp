import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // Import foundation for debugPrint

/// A service class designed to handle chat-related functionalities with Firestore.
/// It encapsulates methods for fetching current user details, their friends,
/// and details of users identified by university ID, among other functionalities.
class ChatService {
  // Instance of FirebaseFirestore used to interact with Firestore.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Instance of FirebaseAuth used to obtain the currently signed-in user.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Asynchronously fetches details of the currently logged-in user.
  ///
  /// It queries the 'users' collection in Firestore using the email address of the
  /// currently logged-in user (if any) to retrieve their details.
  ///
  /// Returns a Map<String, dynamic> representing the user's data if found,
  /// otherwise returns null.
  Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    // Attempt to get the current user from FirebaseAuth.
    final user = _auth.currentUser;
    if (user != null) {
      // If a user is signed in, query their details from the 'users' collection.
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      // Check if the query returned any documents (user details).
      if (querySnapshot.docs.isNotEmpty) {
        // Return the first document's data as the user's details.
        return querySnapshot.docs.first.data();
      }
    }
    // Return null if the user is not logged in or their details are not found.
    return null;
  }

  /// Retrieves a list of friends' IDs for a given user.
  ///
  /// The `userData` parameter is expected to be a Map containing the user's data,
  /// including a 'friends' key pointing to a list of friend IDs.
  ///
  /// Returns a List<String> of friend IDs, or an empty list if the 'friends' key
  /// does not exist or is null in `userData`.
  Future<List<String>> getFriends(Map<String, dynamic> userData) async {
    // Check if userData contains the 'friends' key with a non-null value.
    if (userData.containsKey('friends') && userData['friends'] != null) {
      // Convert and return the value as a List<String> of friend IDs.
      return List<String>.from(userData['friends']);
    }
    // Return an empty list if 'friends' is not found or is null.
    return [];
  }

  /// Fetches details for a user identified by their university ID.
  ///
  /// The `universityId` parameter is the specific ID to query for in the 'users' collection.
  ///
  /// Returns a Map<String, dynamic> with the user's details if found,
  /// otherwise returns null.
  Future<Map<String, dynamic>?> getUserByUniversityId(
      String universityId) async {
    // Query the 'users' collection for a document matching the provided university ID.
    final querySnapshot = await _firestore
        .collection('users')
        .where('universityId', isEqualTo: universityId)
        .get();

    // Check if any documents were found.
    if (querySnapshot.docs.isNotEmpty) {
      // Return the data of the first document found.
      return querySnapshot.docs.first.data();
    }
    // Return null if no matching documents were found.
    return null;
  }

  /// Generates a conversation ID using two user IDs, ensuring lexical order.
  ///
  /// This method takes two user IDs as parameters and sorts them to maintain
  /// a consistent ordering, which is crucial for identifying conversation documents.
  ///
  /// Returns a String formatted as "ID1-ID2" where ID1 is lexically less than ID2.
  String createConversationId(String id1, String id2) {
    // Place both IDs in a list and sort them to ensure a consistent order.
    List<String> ids = [id1, id2];
    ids.sort(); // Lexical sort ensures the first ID is always the smaller one.
    // Join the sorted IDs with a hyphen and return as the conversation ID.
    return ids.join('-'); // The format "ID1-ID2" is used for conversation IDs.
  }

  /// Asynchronously fetches a conversation document from Firestore using its ID.
  ///
  /// The `conversationId` parameter is the ID of the conversation, formatted as "ID1-ID2".
  ///
  /// Returns a DocumentSnapshot representing the conversation's data if found,
  /// or null if the document does not exist or an error occurs.
  Future<DocumentSnapshot?> getConversation(String conversationId) async {
    try {
      // Attempt to retrieve the conversation document by its ID.
      final conversation = await _firestore
          .collection('chat_messages')
          .doc(conversationId)
          .get();
      // Check if the document exists and return it, or return null if not.
      return conversation.exists ? conversation : null;
    } catch (e) {
      // Log any errors encountered during the fetch operation.
      print("Error fetching conversation: $e");
      return null; // Return null in case of an error.
    }
  }

  Stream<DocumentSnapshot> getConversationStream(String conversationId) {
    return FirebaseFirestore.instance
        .collection('chat_messages')
        .doc(conversationId)
        .snapshots();
  }

  /// Asynchronously updates the FCM (Firebase Cloud Messaging) token for the user with the specified [userId].
  ///
  /// Parameters:
  ///   - [userId]: The unique identifier of the user whose FCM token needs to be updated.
  ///   - [fcmToken]: The new FCM token to be associated with the user. Can be null if the token is being cleared.
  ///
  /// Throws an [Exception] if an error occurs during the update process.
  ///

  Future<void> initializeFCMToken(String userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Get the current FCM token
    String? fcmToken = await messaging.getToken();

    // Update the token in Firestore
    await updateFCMToken(userId, fcmToken);
  }

  void listenForTokenRefresh(String userId) {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await updateFCMToken(userId, fcmToken);
    });
  }

  Future<void> updateFCMToken(String userId, String? fcmToken) async {
    try {
      // Update the 'fcmToken' field in the Firestore document associated with the user
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
      });

      // Print a success message to the console
      print(
          'FCM token updated successfully for user $userId and fcmToken is $fcmToken');
    } catch (error) {
      // Print an error message to the console if an error occurs during the update
      print('Error updating FCM token: $error');

      // Throw an exception to indicate that the update operation failed
      throw Exception('Failed to update FCM token');
    }
  }

  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<List<String>?> getCurrentUserCourses() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        if (userDoc.docs.isNotEmpty) {
          Map<String, String> coursesData = Map<String, String>.from(
              userDoc.docs.first.data()['currentCourses'] ?? {});

          List<String> courseCodes = coursesData.keys.toList();

          // Logging the data
          debugPrint('User course codes: $courseCodes');

          return courseCodes;
        } else {
          // Log that no user document was found
          debugPrint('No user document found for email: ${user.email}');
        }
      } catch (e) {
        // Log any errors that occur during the fetch
        debugPrint('Error fetching user course codes: $e');
      }
    } else {
      // Log that no user is logged in if null
      debugPrint('No user logged in');
    }
    return null;
  }

  Future<List<DocumentSnapshot>> findGroupsForCourses(
      List<String> courseCodes) async {
    List<DocumentSnapshot> groupDocs = [];

    for (String courseCode in courseCodes) {
      // Remove spaces from the courseCode
      String formattedCourseCode = courseCode.replaceAll(' ', '');

      // Debugging log for the formatted course code
      debugPrint('Checking for group document with id: $formattedCourseCode');

      try {
        DocumentSnapshot groupDoc = await _firestore
            .collection('groups')
            .doc(formattedCourseCode)
            .get();

        if (groupDoc.exists) {
          groupDocs.add(groupDoc);
          // Debugging log for existing document
          debugPrint('Found group document for course: $formattedCourseCode');
        } else {
          // Debugging log for non-existing document
          debugPrint(
              'No group document found for course: $formattedCourseCode');
        }
      } catch (e) {
        // Debugging log for errors
        debugPrint(
            'Error fetching group document for course: $formattedCourseCode, error: $e');
      }
    }

    return groupDocs;
  }
}
