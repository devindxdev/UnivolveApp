import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Defines a StatefulWidget for a chat room screen in a Flutter application.
class ChatRoomScreen extends StatefulWidget {
  // The name of the person with whom the user is chatting.
  final String personName;

  // The path to the image asset for the person's avatar.
  final String personImageAssetPath;

  // A unique identifier for the current conversation.
  final String conversationId;

  // University ID of the current user, used for identification in the conversation.
  final String currentUserUniversityId;

  // University ID of the friend, used to distinguish messages in the conversation.
  final String friendUniversityId;

  // Constructor for initializing the ChatRoomScreen with required parameters.
  ChatRoomScreen({
    Key? key,
    required this.personName,
    required this.personImageAssetPath,
    required this.conversationId,
    required this.currentUserUniversityId,
    required this.friendUniversityId,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

// Defines the state for the ChatRoomScreen widget.
class _ChatRoomScreenState extends State<ChatRoomScreen> {
  // Controller for managing the text input in the chat message field.
  final TextEditingController _messageController = TextEditingController();

  // Controller for managing scroll behavior in the chat view.
  // It's defined as 'late' because it's initialized immediately in the declaration.
  // This controller allows for programmatically scrolling the chat view.
  late ScrollController _scrollController =
      ScrollController(); // Define _scrollController

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void dispose() {
    // Releases the resources used by the text field controller.
    _messageController.dispose();

    // Cleans up the scroll controller to avoid memory leaks.
    _scrollController.dispose();

    // Calls the dispose method of the superclass to finalize the disposal process.
    super.dispose();
  }

  // This method animates the scroll position to the bottom of the chat list.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      });
    }
  }

  // Asynchronously sends a message typed by the user.
  void _sendMessage() async {
    // Retrieves the current text from the message input field and trims any leading or trailing whitespace.
    final text = _messageController.text.trim();

    // Checks if the trimmed text is empty. If it is, the function exits early.
    // This prevents sending empty messages.
    if (text.isEmpty) return;

    // Fetch the current user's university ID
    // This is just a placeholder for example purposes

    // Creates a map to hold the data for the message being sent.
    Map<String, dynamic> messageData = {
      // Includes the actual message text. This is what the user typed and intends to send.
      'message': text,
      // Identifies the sender of the message by their university ID, providing a way to distinguish between users.
      'sender': widget.currentUserUniversityId,
      'recipient': widget.friendUniversityId,
      // Records the current time using a Timestamp. This is useful for ordering messages and displaying when they were sent.
      'time': Timestamp
          .now(), // Note: Ensure you have imported 'package:cloud_firestore/cloud_firestore.dart' for Timestamp.
    };

    @override
    void initState() {
      super.initState();

      _scrollController = ScrollController();
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // Notification plugin initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings(
              'app_icon'); // Replace 'app_icon' with your actual app icon file name in the Android app's 'res/drawable' folder

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Listen for messages to potentially show notifications
      _listenForMessages();

      // Add a post-frame callback to ensure scrolling happens after the widget build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        _scrollToBottom();
      });
    }

    // Adds the prepared message data to the 'CONVERSATIONHISTORY' field in Firestore.
    FirebaseFirestore.instance
        .collection(
            'chat_messages') // References the 'chat_messages' collection.
        .doc(widget
            .conversationId) // Specifies the document corresponding to the current conversation.
        .update({
      // Utilizes FieldValue.arrayUnion to add the new message data to an existing array in the document.
      // This ensures the message is appended without removing existing messages.
      'CONVERSATIONHISTORY': FieldValue.arrayUnion([messageData]),
    }).then((value) {
      // Once the message is successfully added, clear the message input field.
      _messageController.clear();
      // Scrolls the chat view to the bottom to show the latest message.
      _scrollToBottom();
    }).catchError((error) {
      // If an error occurs during the update, log the error.
      print("Failed to send message: $error");
      // Here, you could extend error handling, for example, by showing a user-friendly error message.
    });
  }

  // Creates a stream that listens for real-time updates to the current conversation's document in Firestore.
  Stream<DocumentSnapshot> _messageStream() {
    // Accesses the FirebaseFirestore instance to query the database.
    return FirebaseFirestore.instance
        .collection(
            'chat_messages') // Specifies the collection of chat messages.
        .doc(widget
            .conversationId) // Targets the specific conversation document using its ID.
        .snapshots(); // Listens for real-time updates, returning a stream of document snapshots.
  }

  void _initNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _listenForMessages() {
    FirebaseFirestore.instance
        .collection('chat_messages')
        .doc(widget.conversationId)
        .snapshots()
        .listen((documentSnapshot) {
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        var conversationHistory =
            data['CONVERSATIONHISTORY'] as List<dynamic>? ?? [];
        if (conversationHistory.isNotEmpty) {
          var lastMessage = conversationHistory.last;
          if (lastMessage['sender'] != widget.currentUserUniversityId) {
            _showNotification(lastMessage['message']);
          }
        }
      }
    });
  }

  Future<void> _showNotification(String message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
        0, 'New Message', message, platformChannelSpecifics,
        payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    // Initially sets the image provider to a default asset image.
    // This image is used if no specific image path is provided or if there's an error loading the provided image.
    ImageProvider imageProvider =
        AssetImage("lib/assets/images/defaultProfilePhoto.png");

    // Checks if the provided image path for the person is a URL (network image).
    // The condition uses `startsWith('http')` to determine if the path is a URL.
    if (widget.personImageAssetPath.startsWith('http')) {
      // If the path is a URL, it uses NetworkImage to load the image from the network.
      imageProvider = NetworkImage(widget.personImageAssetPath);
    } else {
      // If the path is not a URL, it attempts to load the image as an asset.
      try {
        imageProvider = AssetImage(widget.personImageAssetPath);
      } catch (_) {
        // If there's an error loading the image (e.g., the asset path is invalid),
        // it catches the exception and retains the default image provider.
        // This ensures the app doesn't crash due to an image loading error.
        print("Error loading image: ${widget.personImageAssetPath}");
      }
    }
    // The rest of the build method would go here...

// Main layout widget for the chat screen, setting up the app's structure.
    return Scaffold(
      // Defines the app bar at the top of the screen, including styling and navigation.
      appBar: AppBar(
        backgroundColor:
            Color(0xFF2D6A74), // Sets the background color of the AppBar.
        leading: IconButton(
          // Icon button to navigate back to the previous screen.
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Padding(
          // Title section containing the other person's image and name.
          padding: const EdgeInsets.fromLTRB(0, 8.0, 8.0, 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Displays the person's avatar.
              CircleAvatar(
                backgroundImage: imageProvider, // Dynamically loads the image.
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(
                  width: 10), // Spacer for padding between image and text.
              // Displays the person's name with custom styling.
              Text(
                widget.personName,
                style: GoogleFonts.poppins(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),

      // Body of the Scaffold, containing the main chat interface.
      body: Container(
        child: Column(
          children: [
            // Expands to fill the available space, displaying the conversation.
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream:
                    _messageStream(), // Subscribes to message stream for real-time updates.

                builder: (context, snapshot) {
                  // Error handling if the stream encounters an issue.
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  // Displays a loading indicator while waiting for data.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Processes the snapshot data to display chat messages.
                  final documentData =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  final conversationHistory =
                      documentData?['CONVERSATIONHISTORY'] as List<dynamic>? ??
                          [];

                  // Checks if there are messages to display.
                  if (conversationHistory.isNotEmpty) {
                    // Builds a list of message widgets from the conversation history.
                    return ListView.builder(
                      controller:
                          _scrollController, // Controls scrolling behavior.
                      reverse: false, // Starts from the bottom and scrolls up.
                      itemCount:
                          conversationHistory.length, // Number of messages.
                      itemBuilder: (context, index) {
                        // Extracts data for each message.
                        final messageData = conversationHistory[index];
                        final message = messageData['message'] as String;
                        final senderId =
                            messageData['sender'] as String? ?? 'Unknown';
                        final isMe = senderId ==
                            widget
                                .currentUserUniversityId; // Checks if the message was sent by the current user.
                        // Builds a bubble widget for each message.
                        _scrollToBottom();
                        return _buildMessageBubble(
                          context: context,
                          message: message,
                          isMe: isMe,
                          avatarImageProvider: isMe
                              ? null
                              : imageProvider, // Determines the avatar to show based on the sender.
                        );
                      },
                    );
                  } else {
                    // Displays a placeholder text if there are no messages.
                    return Center(child: Text("No messages yet."));
                  }
                },
              ),
            ),
            _buildMessageInputField(), // Adds the message input field at the bottom.
          ],
        ),
      ),
    );
  }

  // Builds the message input field with icons for additional functionalities.
  Widget _buildMessageInputField() {
    return Padding(
      // Adds padding around the container for visual spacing from screen edges.
      padding: const EdgeInsets.only(bottom: 20.0, right: 20, left: 20),
      child: Container(
        // Further padding inside the container for the input field and icons.
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        // Styling the container with a white background, rounded corners, and a subtle shadow.
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 3),
              blurRadius: 5,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
        child: Row(
          // Row widget to horizontally align the icons and the text field.
          children: <Widget>[
            // Icon button for camera access, intended for sending pictures.
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.black),
              onPressed: () {
                // Placeholder for camera functionality.
              },
            ),
            // Icon button for accessing the photo library.
            IconButton(
              icon: Icon(Icons.photo, color: Colors.black),
              onPressed: () {
                // Placeholder for image selection functionality.
              },
            ),
            // Expanding TextField to occupy the remaining space in the Row.
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Enter a message...',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[900]),
                ),
                onSubmitted: (value) {
                  _sendMessage();
                },
              ),
            ),
            // Send button to submit the message.
            IconButton(
              icon: Icon(Icons.send),
              color: Color(0xFF2D6A74),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  // Constructs a bubble for displaying a single message in the chat.
  Widget _buildMessageBubble({
    required BuildContext context,
    required String message, // The message text to display.
    required bool
        isMe, // Boolean to determine if the message was sent by the user.
    ImageProvider<Object>?
        avatarImageProvider, // Optional avatar image for the sender.
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        // Aligns message bubbles to the start or end based on the sender.
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Conditionally includes the sender's avatar for received messages.
          if (!isMe && avatarImageProvider != null) ...[
            const SizedBox(width: 12.0),
            CircleAvatar(
              backgroundImage: avatarImageProvider,
              radius: 16,
            ),
            const SizedBox(width: 8.0),
          ],
          // Flexible container to ensure the message bubble fits within the screen width.
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              // Styling the message bubble with different colors for sent and received messages.
              decoration: BoxDecoration(
                color: isMe ? Color(0xFFCAF2FF) : Color(0xFFCDE7E4),
                borderRadius: isMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        bottomLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
              ),
              // Displays the message text with a predefined style.
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          if (isMe)
            const SizedBox(width: 8.0), // Adds spacing for sent messages.
        ],
      ),
    );
  }
}
