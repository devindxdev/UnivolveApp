import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:univolve_app/pages/AllAuthPages/auth_page.dart';
import 'package:univolve_app/pages/OnboardingPages/onboarding.dart';
import 'package:univolve_app/pages/services/chat_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Handle the background message
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate();
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Handle the error appropriately
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Univolve',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: snapshot.data! ?  AuthPage() :  OnBoardingScreen(),
          );
        }
        return const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Future<bool> _initializeApp() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      await _initializeFirebaseMessaging();
      await _updateFCMToken();

      return hasSeenOnboarding;
    } catch (e) {
      print('Error in _initializeApp: $e');
      // Handle the error appropriately
      return false;
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    try {
      FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
      await FirebaseMessaging.instance.requestPermission(provisional: true);
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
      // Handle the error appropriately
    }
  }

  Future<void> _updateFCMToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $fcmToken');

      final chatService = ChatService();
      final userDetails = await chatService.getCurrentUserDetails();

      if (userDetails != null && fcmToken != null) {
        final String? storedFcmToken = userDetails['fcmToken'];
        final String userId = userDetails['universityId'];
        print("USER ID TESTING: $userId");

        if (storedFcmToken != fcmToken) {
          await chatService.updateFCMToken(userId, fcmToken);
          print('FCM token updated for user $userId');
        } else {
          print('FCM token is up-to-date for user $userId');
        }
      }
    } catch (e) {
      print('Error updating FCM token: $e');
      // Handle the error appropriately
    }
  }
}