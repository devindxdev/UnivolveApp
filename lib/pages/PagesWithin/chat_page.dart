import 'package:dart_openai/dart_openai.dart' as openai_dart;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
//import sdk

import 'package:univolve_app/pages/services/const.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
    token: OPENAI_API_KEY,
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
    // Push an initial message when the page is first initialized
    //Ai Integration done
    print("Chat Page Initialized");
    _pushInitialMessage();
  }

  // Function to push initial message
  void _pushInitialMessage() {
    // Construct an initial message with system prompt and event data
    final initialMessage = ChatMessage(
      text:
          '''HI act like a guide for events who knows things about some recent events happening at TRU, You have data of all the events, if user requests to know anything just give information as per that data. Do not answer anything if it not relevant to this use case and say you strictly prohibited
          
          
          We have a basketBall event coming up on 20th of this month at old main at 10:00 am.
          We have a badminthon event coming up on 25th of this month at old main at 10:00 am.
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
          currentUserContainerColor: Colors.black,
          containerColor: const Color(0xff016D77),
          textColor: Colors.white,
        ),
        onSend: (ChatMessage m) {
          getChatResponse(m);
        },
        messages: _messages,
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
