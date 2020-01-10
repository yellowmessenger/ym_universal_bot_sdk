
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_xmpp/flutter_xmpp.dart';
import './database_helpers.dart';
import './splash.dart';



void main() => runApp(MyApp());

  Stream<String> chatStream;
  var ready;
void _enableStream() {
    if (chatStream == null) {
      chatStream = FlutterXmpp.botStream;
    }
    DatabaseHelper.instance.database;
  }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _enableStream();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: ChatPage(),
   home: SplashPage(chatStream),
    );
  }
}
