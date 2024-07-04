import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:univolve_app/pages/services/chat_services.dart';
import 'package:univolve_app/pages/grouproom_screen.dart';
import 'package:univolve_app/pages/chatroom_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

// ChatScreen StatefulWidget serves as the container for the chat interface in the application.
class ChatScreen extends StatefulWidget {
  @override
  // Creates the state object for this StatefulWidget.
  // _ChatScreenState is where the chat UI and logic are defined.
  _ChatScreenState createState() => _ChatScreenState();
}

// _ChatScreenState contains the state and logic for the ChatScreen widget.
class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  // Instance of ChatService to handle chat-related functionalities such as
  // fetching user details, managing conversations, etc.
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TabController? _tabController;

  late ScrollController _conversationsScrollController = ScrollController();
  late ScrollController _groupsScrollController = ScrollController();

  final TextStyle _titleStyle = GoogleFonts.poppins(
    fontSize: 25.0,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  final TextStyle _subTitleStyle = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  final TextStyle _bodyTextStyle = GoogleFonts.poppins(
    fontSize: 15.0,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    // Initialize the TabController here

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the TabController here
    _tabController?.dispose();
    _conversationsScrollController.dispose();
    _groupsScrollController.dispose();
    super.dispose();
  }

  void _scrollConversationsToBottom() {
    if (_conversationsScrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _conversationsScrollController.animateTo(
          _conversationsScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _scrollGroupsToBottom() {
    if (_groupsScrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _groupsScrollController.animateTo(
          _groupsScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // The number of tabs
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white, Colors.white, Colors.white],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Chat Room', style: _titleStyle),
                  ),
                ),
                
                SizedBox(height: 10),
                SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    labelColor: Color(0xFF2D6A74),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF2D6A74),
                    labelStyle: GoogleFonts.poppins(
                      // Use Poppins for selected tab labels
                      fontWeight: FontWeight
                          .w600, // Adjust the weight as per your design
                      fontSize: 13, // Adjust the size as per your design
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      // Use Poppins for unselected tab labels
                      fontWeight: FontWeight
                          .w600, // Adjust the weight as per your design
                      fontSize: 13, // Adjust the size as per your design
                    ),
                    tabs: [
                      Tab(text: 'Conversations'),
                      Tab(text: 'Course Groups'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _conversationsTabContent(),
                      _groupsTabContent(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Extracted the Conversations tab content into a separate method for cleanliness.
  Widget _conversationsTabContent() {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _chatService.getCurrentUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                      child: Text("User details not found",
                          style: _bodyTextStyle));
                } else {
                  final userDetail = snapshot.data!;
                  final universityId =
                      userDetail['universityId'] as String? ?? '';
                  return FutureBuilder<List<String>>(
                    future: _chatService.getFriends(snapshot.data!),
                    builder: (context, friendSnapshot) {
                      if (friendSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (!friendSnapshot.hasData ||
                          friendSnapshot.data!.isEmpty) {
                        return Center(
                            child: Text("No friends found",
                                style: _bodyTextStyle));
                      } else {
                        return ListView.builder(
                          controller: _conversationsScrollController,
                          itemCount: friendSnapshot.data!.length,
                          itemBuilder: (context, index) {
                            String friendId = friendSnapshot.data![index];

                            return FutureBuilder<Map<String, dynamic>?>(
                              future:
                                  _chatService.getUserByUniversityId(friendId),
                              builder: (context, detailSnapshot) {
                                if (detailSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (!detailSnapshot.hasData ||
                                    detailSnapshot.data == null) {
                                  return ListTile(
                                    title: Text('User not found',
                                        style:
                                            GoogleFonts.poppins(fontSize: 16)),
                                  );
                                } else {
                                  var friendDetails = detailSnapshot.data!;
                                  String name =
                                      friendDetails['username'] ?? 'No Name';
                                  String imagePath = friendDetails[
                                          'photoUrl'] ??
                                      'lib/assets/images/defaultProfilePhoto.png';
                                  return _buildChatTile(context, name,
                                      universityId, friendId, imagePath);
                                }
                              },
                            );
                          },
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendWidget(String name, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 25, backgroundImage: AssetImage(imagePath)),
          SizedBox(height: 5),
          Text(name, style: _bodyTextStyle),
        ],
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, String name, String universityId,
      String userId, String imagePath) {
    final String conversationId =
        _chatService.createConversationId(universityId, userId);

    return StreamBuilder<DocumentSnapshot>(
      stream: _chatService.getConversationStream(conversationId),
      builder: (context, snapshot) {
        String lastMessageText = 'Loading...';
        String lastMessageTime = '';
        bool isLastMessageByCurrentUser =
            false; // Flag to indicate who sent the last message

        if (snapshot.hasData && snapshot.data?.data() != null) {
          var data = snapshot.data?.data() as Map<String, dynamic>;
          if (data.containsKey('CONVERSATIONHISTORY') &&
              data['CONVERSATIONHISTORY'].isNotEmpty) {
            var lastMessage = data['CONVERSATIONHISTORY'].last;
            lastMessageText = lastMessage['message'];
            // Determine if the last message was sent by the current user
            isLastMessageByCurrentUser = lastMessage['sender'] == universityId;

            if (lastMessage['time'] != null) {
              Timestamp ts = lastMessage['time'] as Timestamp;
              DateTime messageDateTime = ts.toDate();
              lastMessageTime = timeago.format(messageDateTime,
                  allowFromNow: true, locale: 'en_short');
            } else {
              lastMessageTime = "N/A";
            }
          } else {
            lastMessageText = 'No messages yet.';
            lastMessageTime = "";
          }
        } else {
          lastMessageText = 'No messages yet.';
          lastMessageTime = "";
        }

        // Customize the display based on who sent the last message
        String messagePrefix = isLastMessageByCurrentUser ? "You: " : "";
        lastMessageText = messagePrefix + lastMessageText;

        return ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey, // Default background color
            backgroundImage: _getImageProvider(imagePath) ??
                AssetImage(
                    'lib/assets/images/defaultProfilePhoto.png'), // Provide a default image in case of null
          ),
          title: Text(name,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, fontSize: 16)),
          subtitle:
              Text(lastMessageText, style: GoogleFonts.poppins(fontSize: 13)),
          trailing: Text(lastMessageTime,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 119, 119, 119))),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                    personName: name,
                    personImageAssetPath: imagePath,
                    conversationId: conversationId,
                    currentUserUniversityId: universityId,
                    friendUniversityId: userId),
              ),
            ).then((_) {
              setState(() {}); // Refresh the UI when coming back to this screen
            });
          },
        );
      },
    );
  }

  ImageProvider? _getImageProvider(String imagePath) {
    if (imagePath == "..." || imagePath.isEmpty) {
      // Return null if the imagePath is not valid
      return null;
    } else if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    } else {
      return AssetImage(imagePath);
    }
  }

  // Inside _ChatScreenState class
// Placeholder method for the Groups tab content.

  Widget _groupsTabContent() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _chatService.getCurrentUserDetails(),
      builder: (context, userDetailsSnapshot) {
        if (userDetailsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (!userDetailsSnapshot.hasData ||
            userDetailsSnapshot.data == null) {
          return Center(
              child: Text("User details not found", style: _bodyTextStyle));
        } else {
          final String universityId =
              userDetailsSnapshot.data!['universityId'] ?? '';
          final String username = userDetailsSnapshot.data!['username'] ?? '';
          final String userAvatar = userDetailsSnapshot.data!['photoUrl'] ?? '';
          return FutureBuilder<List<String>?>(
            future: _chatService.getCurrentUserCourses(),
            builder: (context, coursesSnapshot) {
              if (coursesSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (!coursesSnapshot.hasData ||
                  coursesSnapshot.data!.isEmpty) {
                return Center(
                    child: Text(
                        "No courses found for your profile. Please add your courses from your profile.",
                        style: _bodyTextStyle));
              } else {
                return FutureBuilder<List<DocumentSnapshot>>(
                  future:
                      _chatService.findGroupsForCourses(coursesSnapshot.data!),
                  builder: (context, groupsSnapshot) {
                    if (groupsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (!groupsSnapshot.hasData ||
                        groupsSnapshot.data!.isEmpty) {
                      return Center(
                          child: Text("No groups found for your courses.",
                              style: _bodyTextStyle));
                    } else {
                      return ListView.builder(
                        controller: _groupsScrollController,
                        itemCount: groupsSnapshot.data!.length,
                        itemBuilder: (context, index) {
                          final groupId = groupsSnapshot
                              .data![index].id; // Document ID as groupId
                          final groupName =
                              groupId; // Since you mentioned the document name is the groupName
                          final imagePath =
                              'lib/assets/images/defaultProfilePhoto.png'; // Placeholder for group image path

                          return _buildGroupChatTile(context, groupName,
                              imagePath, universityId, username, userAvatar);
                        },
                      );
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  // Helper method to get a stream of the last message for a group
  Stream<Map<String, dynamic>?> getLastMessageStream(String groupName) {
    // This stream will emit the latest data of the group document whenever it changes
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupName)
        .snapshots()
        .map((snapshot) {
      // Extract the message array from the document
      final messages = snapshot.data()?['message'] as List<dynamic>?;
      // If there are messages, return the last one, otherwise null
      return messages?.isNotEmpty == true
          ? messages!.last as Map<String, dynamic>
          : null;
    });
  }

  Widget _buildGroupChatTile(
      BuildContext context,
      String courseName,
      String defaultImagePath,
      String currentUserId,
      String username,
      String userAvatar) {
    // Combine two streams: one for the last message, and one for the group details
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(courseName)
          .snapshots(),
      builder: (context, snapshot) {
        String lastMessageText = 'Explore the latest messages...';
        String lastMessageTime = 'Just now';
        String photoUrl = defaultImagePath; // Fallback image path

        // Update with actual last message and group details if available
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          Map<String, dynamic>? groupData =
              snapshot.data!.data() as Map<String, dynamic>?;
          if (groupData != null &&
              groupData.containsKey('message') &&
              groupData['message'].isNotEmpty) {
            // Assume the messages are sorted, and the last one is the latest
            Map<String, dynamic> lastMessage = groupData['message'].last;
            lastMessageText = lastMessage['message'] ?? 'No messages yet.';
            Timestamp? ts = lastMessage['timestamp'];
            photoUrl = groupData['photoURL'] ??
                defaultImagePath; // Update the photoURL

            if (ts != null) {
              DateTime messageDateTime = ts.toDate();
              lastMessageTime = DateFormat('hh:mm a').format(messageDateTime);
            } else {
              lastMessageTime = "N/A";
            }
          } else {
            lastMessageText = 'No messages yet.';
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          lastMessageText = 'Loading messages...';
        } else if (snapshot.hasError) {
          lastMessageText = 'Error loading messages.';
          lastMessageTime = '';
        }

        // Now build your ListTile with the actual or default photoUrl
        return ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage:
                (photoUrl.isNotEmpty && photoUrl != defaultImagePath)
                    ? NetworkImage(photoUrl) as ImageProvider<Object>
                    : AssetImage(defaultImagePath) as ImageProvider<Object>,
          ),
          title: Text(courseName,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, fontSize: 16)),
          subtitle:
              Text(lastMessageText, style: GoogleFonts.poppins(fontSize: 13)),
          trailing: Text(lastMessageTime,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupChatRoom(
                  groupName: courseName,
                  currentUserUniversityId: currentUserId,
                  courseAvatar: photoUrl, // Pass the actual photoUrl
                  username: username,
                  userAvatar: userAvatar,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build_group(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groups'),
      ),
      body: _groupsTabContent(),
    );
  }
}
