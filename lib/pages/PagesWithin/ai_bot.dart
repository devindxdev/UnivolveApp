import 'dart:convert';
import 'package:http/http.dart' as http; // Import the http package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart' as openai_dart;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
//import data.developer
import 'dart:developer';

class AIBot extends StatefulWidget {
  const AIBot({Key? key});

  @override
  State<AIBot> createState() => _AIBotState();
}

class _AIBotState extends State<AIBot> {
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
          '''You are here to assist users with course and professor recommendations at TRU. Your knowledge encompasses data on all courses and professors at TRU. Ensure to only provide information related to courses and professors at TRU.
          If the user asks for information about a professor, obtain the full name of the professor. Once you have obtained the name of the professor, you must reply with the following JSON message. Replace the <Prof name> with the prof name
          DO NOT ASK FOR MORE INFORMATION, ONCE YOU HAVE OBTAINED THE FULL NAME, REPLY WITH THE FOLLOWING

          {
              "prof": "<Prof name>",
          }
          
          If you can't find the requested information, ask the user for the missing information as long as they want to know information about a professor. 

           Now, Greet the user first and then await their questions regarding courses or professors at TRU. 
          ''',
      user: _currentUser,
      createdAt: DateTime.now(),
    );

    // Add the initial message to the chat
    getChatResponse(initialMessage);
  }

  // Method to analyze reply from LLM and take appropriate action
  void analyzeAndHandleReply(String reply) {
    pushReplyToUI(reply);
    print("Reply from GPT: $reply");

    int braceCount = 0;
    int startIndex = -1;
    // Loop through the reply to find the first complete JSON object
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '{') {
        braceCount++;
        if (startIndex == -1)
          startIndex = i; // Mark the start of the JSON object
      } else if (reply[i] == '}') {
        braceCount--;
        if (braceCount == 0 && startIndex != -1) {
          // Found a complete JSON object
          String matchedJson = reply.substring(startIndex, i + 1);
          try {
            // Attempt to decode the extracted JSON string
            final decoded = jsonDecode(matchedJson);
            print("The json has been decoded: Decoded JSON: $decoded");

            if (decoded is Map<String, dynamic>) {
              print("Request handled successfully to manafeRequest");

              manageRequest(decoded);
              return; // Exit after handling the first valid JSON object
            }
          } catch (e) {
            print("Failed to decode JSON or handle the reply: $e");
          }
          break; // Stop after the first match (remove this if you want to find all matches)
        }
      }
    }

    // If no JSON object is found or processed, continue with your logic
    pushReplyToUI(reply);
  }

  // Method to manage requests based on the JSON content
  void manageRequest(Map<String, dynamic> request) {
    // Check the keys in the JSON object to determine the action
    if (request.containsKey('prof')) {
      getProfDetails(request['prof']);
    } else if (request.containsKey('course')) {
      getCourseDetails(request['course']);
    } else if (request.containsKey('reply')) {
      // If there's a 'reply' key, push its content to the UI
      pushReplyToUI(request['reply']);
    }
  }

  // Method to fetch professor details from the API
  Future<void> getProfDetails(String profName) async {
    print("Fetching details for professor: $profName");

    // Replace spaces with '%20' for URL encoding
    final String encodedName = Uri.encodeComponent(profName);
    final String url =
        'https://rate-my-api-691fa4743c8d.herokuapp.com/professor?name=$encodedName';

    try {
      // Make the HTTP GET request to the API
      var response = await http.get(Uri.parse(url));

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Success - Decode the response body to JSON and log it
        final response = await http.get(Uri.parse(url));
        final jsonResponse = jsonDecode(response.body);
        print("The response from the API is: $jsonResponse");

        //push the string to Chat GPt to draft a suitable reply

        final String prompt =
            "Below are the prof details, summarize  how the prof is: $jsonResponse";
        print("Prompt for GPT: $prompt");
        final request = ChatCompleteText(
          model: GptTurbo0301ChatModel(),
          messages: createChatMessages(prompt),
          maxToken: 200,
        );

        final responseAi = await _openAI.onChatCompletion(request: request);
        for (var element in responseAi!.choices) {
          if (element.message != null) {
            print("The response from GPT is: ${element.message!.content}");
            pushReplyToUI(element.message!.content);
          }
        }
        setState(() {
          _typingUsers.remove(_gptChatUser);
        });
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        print(
            "Failed to load professor details. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Catch any exceptions and print them to the console
      print("Failed to load professor details: $e");
    }
  }

  List<Map<String, dynamic>> createChatMessages(String prompt) {
    return [
      {
        'role':
            'user', // Assuming the role 'user' for simplicity; adjust as needed
        'content': prompt
      }
    ];
  }

  // Placeholder for the getCourseDetails method
  void getCourseDetails(String courseCode) {
    // Implement fetching course details and pushing them to the UI
    print("Fetching details for course: $courseCode");
  }

  // Method to push replies to the UI
  void pushReplyToUI(String reply) {
    // This is where you could add the reply to your messages list and update the UI accordingly
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          user: _gptChatUser,
          createdAt: DateTime.now(),
          text: reply,
        ),
      );
    });
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
          'Advisor AI',
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
        analyzeAndHandleReply(element.message!.content);
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
