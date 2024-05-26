import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:univolve_app/pages/AllAuthPages/auth_page.dart';
import 'package:univolve_app/pages/OnboardingPages/onboarding.dart';
// import 'package:univolve_app/pages/onboarding_screens.dart';
import 'package:univolve_app/pages/services/chat_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Handle the background message
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  final notificationSettings =
      await FirebaseMessaging.instance.requestPermission(provisional: true);

  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  final fcmToken = null; //await FirebaseMessaging.instance.getToken();
  print('FCM Token: $fcmToken');

//1. Obtain current user doc
  final chatService = ChatService();
  final userDetails = await chatService.getCurrentUserDetails();
  // Assuming `getCurrentUserDetails` returns a Map with userDetails and includes 'fcmToken' and 'userId' keys

  // Check and update FCM token logic
  if (userDetails != null) {
    final String? storedFcmToken = userDetails['fcmToken'];
    final String userId = userDetails['universityId'];
    print("USER ID TESTING: $userId");
    if (fcmToken != null && storedFcmToken != fcmToken) {
      // FCM token is different or not set for the user, update it
      await chatService.updateFCMToken(userId, fcmToken);
      print('FCM token updated for user $userId');
    } else {
      print('FCM token is up-to-date for user $userId');
    }
  }

//2. check if user has FCM token,
//3. if not, update user doc with FCM token
//4. if user has FCM token, check if it is the same as the current FCM token
//5. if not, update user doc with new FCM token
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Univolve',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: hasSeenOnboarding ? AuthPage() : OnBoardingScreen(),
    );
  }
}
