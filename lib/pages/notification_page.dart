import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Widget> notifications = []; // List to hold notification widgets

  // Function to add a notification to the list
  void addNotification(Widget notification) {
    setState(() {
      notifications.add(notification);
    });
  }

  // Function to remove a notification from the list
  void removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  // Function to show Snackbar with a message
  void showSnackbar(String message, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        // onClosed: () {
        //   removeNotification(index);
        // },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Adding initial notifications to the list
    notifications.addAll([
      // Friend Request Notification
      _buildConnectionRequestCard(
        'Jimi Hingu wants to connect with you!',
        'Accept',
        'Reject',
        true,
      ),
      // Event Notification
      _buildEventNotificationCard(
        'TRU Computer Science club has a lan party on May 16.',
        'Like',
        'Remove',
      ),
      // Another Friend Request Notification
      _buildConnectionRequestCard(
        'Jimi Hingu wants to connect with you!',
        'Accept',
        'Reject',
        true,
      ),
      // Another Event Notification
      _buildEventNotificationCard(
        'TRU Music Club has a jamming session on May 21.',
        'Like',
        'Remove',
      ),
    ]);
  }

  Widget _buildConnectionRequestCard(String text, String acceptButtonText,
      String rejectButtonText, bool isFriendRequest) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: ListTile(
        tileColor: Color(0xFFEDF6F9),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              'https://firebasestorage.googleapis.com/v0/b/univolve-project.appspot.com/o/profilePictures%2FT00704197?alt=media&token=1f2c6a90-33bb-47f8-b0e2-5ee554595ea6'), // Replace with your asset or network image
        ),
        title: Text(text),
        trailing: isFriendRequest
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      var notification = _buildConnectionRequestCard(
                        text,
                        acceptButtonText,
                        rejectButtonText,
                        isFriendRequest,
                      );
                      showSnackbar('Request accepted',
                          notifications.indexOf(notification));
                    },
                    child: Text(acceptButtonText),
                    style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF84C5BE),
                        foregroundColor: Colors.white),
                  ),
                  SizedBox(width: 10), // Add spacing between buttons
                  TextButton(
                    onPressed: () {
                      var notification = _buildConnectionRequestCard(
                        text,
                        acceptButtonText,
                        rejectButtonText,
                        isFriendRequest,
                      );
                      showSnackbar('Request rejected',
                          notifications.indexOf(notification));
                    },
                    child: Text(rejectButtonText),
                    style: TextButton.styleFrom(
                        backgroundColor: Color(0xff999796),
                        foregroundColor: Colors.white),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildEventNotificationCard(
      String text, String likeButtonText, String removeButtonText) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              'https://raw.githubusercontent.com/Singh-Gursahib/Univolve/master/lib/assets/images/photo_for_event/Comp-events.jpg'), // Replace with your asset or network image
        ),
        title: Text(text),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                var notification = _buildEventNotificationCard(
                  text,
                  likeButtonText,
                  removeButtonText,
                );
                showSnackbar('Liked', notifications.indexOf(notification));
              },
              child: Text(likeButtonText),
              style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF84C5BE),
                  foregroundColor: Colors.white),
            ),
            SizedBox(width: 10), // Add spacing between buttons

            TextButton(
              onPressed: () {
                var notification = _buildEventNotificationCard(
                  text,
                  likeButtonText,
                  removeButtonText,
                );
                showSnackbar('Removed', notifications.indexOf(notification));
              },
              child: Text(removeButtonText),
              style: TextButton.styleFrom(
                  backgroundColor: Color(0xff999796),
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView(
        children: notifications,
      ),
    );
  }
}
