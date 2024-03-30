import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupName;
  final String currentUserUniversityId;
  final String courseAvatar;
  final String username;
  final String userAvatar;

  GroupChatRoom({
    Key? key,
    required this.groupName,
    required this.currentUserUniversityId,
    required this.courseAvatar,
    required this.username,
    required this.userAvatar,
  }) : super(key: key);

  @override
  _GroupChatRoomState createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final message = {
        'isAnonymous': false,
        'message': messageText,
        'senderID': widget.currentUserUniversityId,
        'timestamp': Timestamp.now(),
        'username': widget.username,
        'userAvatar': widget.userAvatar,
      };

      FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupName)
          .update({
        'message': FieldValue.arrayUnion([message]),
      }).then((value) {
        _messageController.clear();
        if (messageText.contains('@everyone')) {
          _triggerEveryoneNotification(); // New method call
        }
      }).catchError((error) {
        print("Failed to send message: $error");
      });

      _messageController.clear();
      _scrollToBottom();
    }
  }

  // This is a placeholder for your actual notification trigger logic
  void _triggerEveryoneNotification() {
    print("Triggering @everyone notification");

    // Here you would implement your call to a backend service or cloud function
    // For example, making an HTTP request to your server with details about the notification
  }

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

  Stream<DocumentSnapshot<Map<String, dynamic>>> _messageStream() {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupName)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2D6A74), // Example color, adjust as needed
        title: Text(widget.groupName,
            style: GoogleFonts.poppins(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _messageStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("Error fetching messages: ${snapshot.error}");
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Log the entire document snapshot data for inspection

                final data = snapshot.data?.data();
                final messages = data != null && data['message'] is List
                    ? data['message'] as List<dynamic>
                    : [];

                // Log the messages list for inspection
                print("Extracted messages: $messages");

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final messageText = messageData['message'] as String;
                    final String senderID =
                        messageData['senderID'] as String? ?? "";
                    final isMe = senderID == widget.currentUserUniversityId;

                    // Additional log inside itemBuilder if needed
                    // Useful for debugging individual messages
                    // print("Message at index $index: $messageData");
                    _scrollToBottom();
                    return _buildMessageBubble(
                      context: context,
                      message: messageText,
                      isMe: isMe,
                      username: isMe ? null : widget.username,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required BuildContext context,
    required String message,
    required bool isMe,
    String? senderID,
    String? username, // Include username in the parameter
  }) {
    ImageProvider<Object>? avatarImageProvider;

    // Determine avatarImageProvider based on userAvatar
    if (!isMe && widget.userAvatar != null && widget.userAvatar.isNotEmpty) {
      avatarImageProvider = (widget.userAvatar.startsWith('http')
          ? NetworkImage(widget.userAvatar)
          : AssetImage(widget.userAvatar)) as ImageProvider<Object>?;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe && username != null)
            Text(
              username, // Display the username above the message bubble
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: 12.0,
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && avatarImageProvider != null) ...[
                CircleAvatar(
                  backgroundImage: avatarImageProvider,
                  radius: 16,
                ),
                const SizedBox(width: 8.0),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
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
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 8.0), // Spacing for sent messages
            ],
          ),
        ],
      ),
    );
  }

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
}
