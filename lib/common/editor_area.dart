import 'package:flutter/material.dart';
import 'package:flutter_xmpp/flutter_xmpp.dart';
import 'package:intl/intl.dart';
import 'package:ym_universal_bot_sdk/models/Message.dart';
import '../database_helpers.dart';
import '../utils/colors.dart';

class EditorArea extends StatefulWidget {
  @override
  _EditorAreaState createState() => _EditorAreaState();
}

class _EditorAreaState extends State<EditorArea> {
  final TextEditingController _textEditingControllerInteraction = TextEditingController();
  bool _isComposingMessage = false;

  RaisedButton _getDefaultSendButton() {
    return RaisedButton(
      color: _isComposingMessage ? YellowColor : PrimaryAccentColor,
      shape: CircleBorder(),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingControllerInteraction.text)
          : () {
            // TODO: Implement Speech recognition.
          },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          _isComposingMessage ? Icons.send : Icons.mic,
          color: TextColorLight,
          size: 30.0,
        ),
      ),
    );
  }

  Future<Null> _textMessageSubmitted(String text) async {
    DateTime now = DateTime.now();
    var queueMessage =
        Message(text, DateFormat('kk:mm').format(now), true, true);
    sendMessage(text);
    _saveMessage(queueMessage);
    _textEditingControllerInteraction.clear();
  }

  refresh(String message) {
    _textMessageSubmitted(message);
    // suggestions.clear();
  }
  

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  MediaQuery.of(context).size.height / 8,
      width: MediaQuery.of(context).size.width,
      color: PrimaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: TextField(
                cursorColor: TextColorLight,
                style: TextStyle(color: Colors.white, fontSize: 20),
                controller: _textEditingControllerInteraction,
                onChanged: (String messageText) {
                  setState(() {
                    _isComposingMessage = messageText.length > 0;
                  });
                },
                onSubmitted: null,
                decoration:
                    InputDecoration.collapsed(
                      hintText: "Let's talk.", 
                      hintStyle: TextStyle(color: primaryTextColor, fontSize: 20)
                      ),
              ),
            ),
            Wrap(
              children: <Widget>[
                _getDefaultSendButton(),
              ],
            ),
          ],
        ),
      ),
    );
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