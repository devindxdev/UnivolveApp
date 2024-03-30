import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart' as openai_dart;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
//import sdk

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
    token: "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",
    baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 5,
      ),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'TRU', lastName: 'Student');

  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: 'Univolve', lastName: 'Bot');

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  // Define your event data as a string
  static const String eventData = "Your event data here...";

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection('events').get();
      List<Map<String, dynamic>> eventData =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      // Convert eventData to JSON
      String eventDataJson = convertDataToJson(eventData);

      // Push initial message with event data
      _pushInitialMessage(eventDataJson);
    } catch (error) {
      print("Error fetching data from Firestore: $error");
      // Handle error appropriately
    }
  }

  String convertDataToJson(List<Map<String, dynamic>> eventData) {
    List<Map<String, dynamic>> jsonData = [];

    for (var event in eventData) {
      Map<String, dynamic> jsonEvent = {};
      event.forEach((key, value) {
        if (value is Timestamp) {
          // Convert Timestamp to milliseconds since epoch
          jsonEvent[key] = value.millisecondsSinceEpoch;
        } else {
          jsonEvent[key] = value;
        }
      });
      jsonData.add(jsonEvent);
    }

    return jsonEncode(jsonData);
  }

  // Function to push initial message
  // Function to push initial message with event data
  void _pushInitialMessage(String eventDataJson) {
    // Construct initial message with event data
    final initialMessage = ChatMessage(
      text:
          '''HI act like a guide for events who knows things about some recent events happening at TRU, You have data of all the events, if user requests to know anything just give information as per that data. Do not answer anything if it not relevant to this use case and say you strictly prohibited
          
          
          $eventDataJson

          now you will be asked the questions about the events happening at TRU from the user ahead. Act like a helper and greet user first. 
          ''',
      user: _currentUser,
      createdAt: DateTime.now(),
    );

    // Add the initial message to the chat
    getChatResponse(initialMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff016D77),
        title: const Text(
          'Univolve AI Chatbot',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: DashChat(
        currentUser: _currentUser,
        typingUsers: _typingUsers,
        messageOptions: const MessageOptions(
          containerColor: Color.fromARGB(255, 222, 222, 222),
          currentUserContainerColor: const Color(0xff016D77),
          textColor: Colors.black,
        ),
        onSend: (ChatMessage m) {
          getChatResponse(m);
        },
        messages: _messages.reversed
            .skip(1)
            .toList()
            .reversed
            .toList(), // Reverse twice
// Reverse and skip the first message
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });

    // Convert _messages to a list of Maps instead of a list of Messages objects
    List<Map<String, dynamic>> _messagesHistory = _messages.reversed.map((m) {
      return {
        "role": m.user == _currentUser ? "user" : "assistant",
        "content": m.text,
      };
    }).toList();

    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messagesHistory, // Now passing a List<Map<String, dynamic>>
      maxToken: 200,
    );

    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
                user: _gptChatUser,
                createdAt: DateTime.now(),
                text: element.message!.content),
          );
        });
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
