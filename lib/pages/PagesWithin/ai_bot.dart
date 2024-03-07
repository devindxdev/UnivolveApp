import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  ChatUser myself = ChatUser(
    id: '1',
    firstName: 'Jimil',
  );
  ChatUser bot = ChatUser(
    id: '2',
    firstName: 'Univolve Bot',
  );

  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];

  String ourUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBXlmSOFQ43ceI9Vbb1yh0ft9s61SseB7k';

  getData(ChatMessage m) async {
    typing.add(bot);
    allMessages.insert(0, m);

    setState(() {});

    await http
        .post(
      Uri.parse(ourUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'contents': [
          {
            'parts': [
              {
                'text': m.text,
              }
            ]
          }
        ]
      }),
    )
        .then((value) {
      if (value.statusCode == 200) {
        var data = jsonDecode(value.body);
        print(data);
        print(data['candidates'][0]['content'][0]['parts'][0]['text']);

        ChatMessage m1 = ChatMessage(
          text: data['candidates'][0]['content'][0]['parts'][0]['text'],
          user: bot,
          createdAt: DateTime.now(),
        );

        allMessages.insert(0, m1);
      } else {
        print("****Error: " + value.body);
      }
    }).catchError((e) {
      print("****Error: " + e);
    });
    typing.remove(bot);
    setState(() {
      // allMessages = allMessages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
          body: DashChat(
        typingUsers: typing,
        currentUser: myself,
        messages: allMessages,
        onSend: (ChatMessage m) {
          getData(m);
        },
      )),
    );
  }
}
