import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_xmpp/bot_config.dart';
import 'package:flutter_xmpp/flutter_xmpp.dart';
import 'package:intl/intl.dart';

import 'common/editor_area.dart';
import 'common/reply_area.dart';
import 'common/suggestions.dart';
import 'common/topbar.dart';
import 'database_helpers.dart';
import 'models/Message.dart';
import 'models/quick_replies.dart';
import 'services/botConfigService.dart';
import 'services/url_launcher.dart';
import 'utils/colors.dart';

class Interaction extends StatefulWidget {
  @override
  _InteractionState createState() => _InteractionState();
}

class _InteractionState extends State<Interaction> {
  StreamSubscription chatStream;
  bool ready = false;
  List<Widget> replyAreaContent = [];
  List<Widget> suggestions = [];

  void _enableStream() {
    if (chatStream == null) {
      chatStream = FlutterXmpp.botStream.listen(_updateChat);
    }
  }

  Future<void> initChannels(BotConfig myBot) async {
    ready = await FlutterXmpp.initialize(myBot);
    print(ready);
  }

  @override
  void initState() {
    super.initState();
    BotConfigService.loadAsset().then((v) {
      var config = json.decode(v);
      BotConfig myBot =
          BotConfig(config['botId'], config['botName'], config['authToken']);
      initChannels(myBot);
    });
    _enableStream();
  }

  void _setSuggestions(List<Options> quickReplies) {
    if (quickReplies != null) {
      for (var option in quickReplies) {
        setState(() {
          suggestions.add(OutlineButton(
              child: option.image != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        CircleAvatar(
                            backgroundImage: NetworkImage(option.image)),
                        Html(data: option.title)
                      ],
                    )
                  : Html(data: option.title),
              onPressed: () {
                if (option.text != null && option.text != '') {
                  sendMessage(option.text);
                } else if (option.url != null && option.url != '') {
                  UrlLauncher.launchURL(option.url);
                }
                suggestions.clear();
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0))));
          suggestions.add(SizedBox(width: 4));
        });
      }
    }
  }

  // Main UI
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final logoHeight = screenHeight * 0.5;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Transform.translate(
            offset: Offset(screenWidth * 0.3, 0),
            child: Transform.rotate(
              angle: -0.3,
              child: Image.asset(
                "images/logo.png",
                height: logoHeight,
                color: logoTintColor,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Column(
              children: <Widget>[
                Suggestions(suggestions),
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).cardColor),
                  child: EditorArea(),
                ),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
              child: Column(
                children: <Widget>[
                  TopBar(""),
                  Column(
                    children: replyAreaContent,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateChat(String data) {
    print(data);
    DateTime now = DateTime.now();
    if (data == "Initializing...") {
      setState(() {
        replyAreaContent.add(ReplyArea(Message("Inititalizing Bot",
            DateFormat('kk:mm').format(now), true, false)));
      });
    } else {
      var replyText = json.decode(data);
      if (replyText['message'] != null) {
        setState(() {
          _saveMessage(Message(replyText['message'],
              DateFormat('kk:mm').format(now), true, false));
          replyAreaContent.add(ReplyArea(replyText['message']));
        });
      } else if (replyText['quickReplies'] != null) {
        QuickReplies quickReplies =
            QuickReplies.fromJson(replyText['quickReplies']);

        setState(() {
          replyAreaContent.add(ReplyArea(Message(
              quickReplies.title, DateFormat('kk:mm').format(now), true, false,
              format: MessageFormats.QuickReplies,
              quickReplies: quickReplies.options)));
          _setSuggestions(quickReplies.options);
        });
        _saveMessage(Message(
            quickReplies.title, DateFormat('kk:mm').format(now), true, false,
            format: MessageFormats.QuickReplies));
      }
    }
  }
}

Future<String> sendMessage(String msgBody) async {
  String msg = await FlutterXmpp.sendMessage(msgBody);
  return msg;
}

_saveMessage(Message messageData) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int id = await helper.insertMessage(messageData);
  print('inserted row: $id');
}

//To remove after testing
_clearTable() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  await helper.clearTable();
  print('deleted Table');
}
