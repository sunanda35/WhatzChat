import 'package:flutter/material.dart';
import 'package:whatzzchat/chat/chatting.dart';
import 'package:whatzzchat/chat/public.dart';
import 'package:whatzzchat/profile/authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'Public',
      routes: {
        'Public': (context)=>ChatPublic(),
        'chatting': (context)=>Chatting(),
          'auth' : (cotext)=>chatapp(),
      },
    );   //VoiceCall(),
  }
}