import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../widget/chat_messages.dart';
import '../widget/new_message.dart';

final _firebase = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // push notification function async await can't be used on iniState

  void setupPushNotification() async {
    final firebaseCloudMessaging = FirebaseMessaging.instance;

    // final notificationSettings =  await firebaseCloudMessaging.requestPermission();

    await firebaseCloudMessaging.requestPermission();

    // using this token we can only notify message to that device we want every notification in all device
    //  final token = await firebaseCloudMessaging.getToken();
    //  print("Token :  ${token}");

    firebaseCloudMessaging.subscribeToTopic("chat");
  }

  @override
  void initState() {
    super.initState();

    setupPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chattre-Man"),
        actions: [
          IconButton(
              onPressed: () {
                _firebase.signOut();
              },
              icon: Icon(Icons.exit_to_app,
                  color: Theme.of(context).colorScheme.primary))
        ],
      ),
      body: Column(children: const [
        // showing sended messages s
        Expanded(child: ChatMessages()),

        // Textfield for sending new messages
        NewMessage(),
      ]),
    );
  }
}
