import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_xmpp/flutter_xmpp.dart';

import 'models/configMap.dart';
import 'common/bubble.dart';
import 'database_helpers.dart';
import 'models/cards.dart';
import 'models/quick_replies.dart';
import 'services/messengerService.dart';
import 'utils/colors.dart';
import 'models/Message.dart';

ScrollController _scrollController = new ScrollController();

final TextEditingController _textEditingController = TextEditingController();
bool _isComposingMessage = false;

double maxWidth = 0.0;

class ChatPage extends StatefulWidget {
  final Stream<String> chatStream;
  final String homeButtonMessage;

  ChatPage(this.chatStream, this.homeButtonMessage);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  File _image;
  String getPermission = '';
  List<Widget> bubbles = [];
  bool _isAvailable = false;
  bool ready = false;
  StreamSubscription chatStreamSubscription;
  List<Widget> suggestions = [];
  ConfigMap configMap;
  bool hideInput = false;

  _getConfigurations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      configMap = ConfigMap(
        prefs.getString('botName'),
        prefs.getString('botTitle'),
        prefs.getString('botDesc'),
        prefs.getString('botIntro'),
        prefs.getString('botIcon'),
      );
    });
  }

  String resultText = "";
  DateTime now = DateTime.now();
  Future getImage() async {
    try {
      var image = await ImagePicker.pickImage(source: ImageSource.camera);
      setState(() {
        _image = image;
        print("Image Selected.");

        bubbles.add(Bubble(
            msg: Message(
                _image.path, DateFormat('kk:mm').format(now), false, true,
                format: MessageFormats.Image, isLocalFile: true)));
      });

      _saveMessage(Message(
          _image.path, DateFormat('kk:mm').format(now), false, true,
          format: MessageFormats.Image, isLocalFile: true));
    } catch (e) {
      print(e);
    }
  }

  _enableStream() {
    if (chatStreamSubscription == null) {
      chatStreamSubscription = widget.chatStream.listen(_updateChat);
    }
  }

  void _updateChat(String data) {
    print(data);
    DateTime now = DateTime.now();
    if (data == "Initializing...") {
    } else {
      var replyText = json.decode(data);
      if (replyText['message'] != null) {
        setState(() {
          bubbles.add(Bubble(
              msg: Message(replyText['message'],
                  DateFormat('kk:mm').format(now), true, false)));

          _saveMessage(Message(replyText['message'],
              DateFormat('kk:mm').format(now), true, false));
        });
      } else if (replyText['quickReplies'] != null) {
        QuickReplies quickReplies =
            QuickReplies.fromJson(replyText['quickReplies']);
          if(quickReplies.multiSelect){
            setState(() {
           bubbles.add(Bubble(
            msg: Message(quickReplies.title, DateFormat('kk:mm').format(now),
                true, false,
                format: MessageFormats.MultiSelect,
                quickRepliesMulti: quickReplies.options
              ),
            notifyParent: refresh,
          ));

          _saveMessage(Message(
              quickReplies.title, DateFormat('kk:mm').format(now), true, false,
              format: MessageFormats.QuickReplies));
        });
          }
          else{
        setState(() {
          bubbles.add(Bubble(
            msg: Message(quickReplies.title, DateFormat('kk:mm').format(now),
                true, false,
                format: MessageFormats.QuickReplies,
                quickReplies: quickReplies.options),
            notifyParent: refresh,
          ));
          _setSuggestions(quickReplies.options);

          _saveMessage(Message(
              quickReplies.title, DateFormat('kk:mm').format(now), true, false,
              format: MessageFormats.QuickReplies));
        });
          }
      } else if (replyText['image'] != null) {
        setState(() {
          bubbles.add(Bubble(
            msg: Message(replyText['image'], DateFormat('kk:mm').format(now),
                true, false,
                format: MessageFormats.Image),
          ));
          _saveMessage(Message(
              replyText['image'], DateFormat('kk:mm').format(now), true, false,
              format: MessageFormats.Image));
        });
      } else if (replyText['video'] != null) {
        setState(() {
          bubbles.add(Bubble(
              msg: Message(replyText['video']['url'],
                  DateFormat('kk:mm').format(now), true, false,
                  format: MessageFormats.Video)));
          _saveMessage(Message(replyText['video']['url'],
              DateFormat('kk:mm').format(now), true, false,
              format: MessageFormats.Video));
        });
      } else if (replyText['cards'] != null) {
        CardResponse cards = CardResponse.fromJson(replyText);
        setState(() {
          bubbles.add(Bubble(
            msg: Message('', DateFormat('kk:mm').format(now), true, false,
                format: MessageFormats.CardsResponse, cards: cards),
            notifyParent: refresh,
          ));
          _saveMessage(Message('', DateFormat('kk:mm').format(now), true, false,
              format: MessageFormats.CardsResponse, cards: cards));
        });
      }

      if (replyText['hideInput'] != null) {
        setState(() {
          hideInput = replyText['hideInput'];
        });
      } else {
        hideInput = false;
      }

      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  void _setSuggestions(List<Options> quickReplies) {
    if (quickReplies != null) {
      suggestions = [];
      for (var option in quickReplies) {
        setState(() {
          suggestions.add(OutlineButton(
              highlightedBorderColor: Colors.blue,
              child: option.image != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        CircleAvatar(
                            backgroundImage: NetworkImage(option.image)),
                        Html(data: option.title)
                      ],
                    )
                  : Html(
                      data: option.title,
                      shrinkToFit: true,
                    ),
              onPressed: () {
                if (option.text != null && option.text != '') {
                  refresh(option.text, title: option.title);
                } else if (option.url != null && option.url != '') {
                  _launchURL(option.url);
                } else {
                  refresh(option.title);
                }
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0))));
          suggestions.add(SizedBox(width: 4));
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getConfigurations();
    _enableStream();
    //Creating chat bubbles
    if (bubbles.length == 0)
      _readMessage(1).then((oldMessages) {
        setState(() {
          for (var message in oldMessages) {
            bubbles.add(Bubble(msg: message, notifyParent: refresh));
          }
        });
      });
    MessengerService.sendMessage(widget.homeButtonMessage);
  }

  @override
  void dispose() {
    chatStreamSubscription.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    maxWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          //  TopBar(configMap.botIcon)
          backgroundColor: Color.fromRGBO(0, 102, 167, 1),
          leading: Hero(
            tag: "boticon",
            child: Image.network(configMap.botIcon),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(configMap.botName),
              Text(configMap.botDesc, style: TextStyle(fontSize: 13)),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              color: Colors.white,
              onPressed: () => MessengerService.sendMessage('Hi'),
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    child: _chatBubbles(),
                  ),
                ),
                Divider(height: 4.0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: suggestions,
                    ),
                  ),
                ),
                Divider(height: 4.0),
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).cardColor),
                  child: hideInput
                      ? Container(
                          height: 20,
                        )
                      : _messageEditor(),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _chatBubbles() {
    return ListView(
        controller: _scrollController,
        reverse: true,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: bubbles,
          ),
        ]);
  }

  Container _messageEditor() {
    return Container(
      height: MediaQuery.of(context).size.height / 9,
      width: MediaQuery.of(context).size.width,
      color: PrimaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.attach_file),
              onPressed: getImage,
            ),
            Flexible(
              child: TextField(
                cursorColor: TextColorLight,
                style: TextStyle(color: Colors.white, fontSize: 20),
                controller: _textEditingController,
                textInputAction: TextInputAction.send,
                onChanged: (String messageText) {
                  setState(() {
                    _isComposingMessage = messageText.length > 0;
                  });
                },
                onEditingComplete: _sendFromKeyboard,
                onSubmitted: null,
                decoration: InputDecoration.collapsed(
                    hintText: "Send a message",
                    hintStyle:
                        TextStyle(color: primaryTextColor, fontSize: 20)),
              ),
            ),
            Wrap(
              children: <Widget>[
                _getDefaultSendButton(),
                // IconButton(
                //   icon: Icon(Icons.add_a_photo),
                //   onPressed: getImage,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _sendFromKeyboard() {
    if (_textEditingController.text.isNotEmpty)
      _textMessageSubmitted(_textEditingController.text);
    FocusScope.of(context).unfocus();
  }

  RaisedButton _getDefaultSendButton() {
    return RaisedButton(
      color: Colors.blue,
      shape: CircleBorder(),
      onPressed: () => _textMessageSubmitted(_textEditingController.text),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.send,
          color: TextColorLight,
          size: 30.0,
        ),
      ),
    );
  }

  Future<Null> _textMessageSubmitted(String text, {String title}) async {
    DateTime now = DateTime.now();
    print(title);
    var queueMessage = Message(title != null ? title : text,
        DateFormat('kk:mm').format(now), true, true);
    setState(() {
      bubbles.add(Bubble(msg: queueMessage));
    });
    sendMessage(text);
    _saveMessage(queueMessage);
    _textEditingController.clear();
    setState(() {
      _isComposingMessage = false;
    });
  }

  refresh(String message, {String title}) {
    title != null
        ? _textMessageSubmitted(message, title: removeAllHtmlTags(title))
        : _textMessageSubmitted(removeAllHtmlTags(message));
    suggestions.clear();
  }
}

Future<String> sendMessage(String msgBody) async {
  String msg = await FlutterXmpp.sendMessage(msgBody);
  return msg;
}

Future<List<Message>> _readMessage(int rowId) async {
  DatabaseHelper helper = DatabaseHelper.instance;

  List<Message> messagesData = await helper.queryMessage(rowId);
  if (messagesData == null) {
    print('read row $rowId: empty');
    return null;
  } else {
    for (var messageData in messagesData) {
      print('read row ${messageData.id}: ${messageData.message}');
    }
    return messagesData;
  }
}

_saveMessage(Message messageData) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int id = await helper.insertMessage(messageData);
  print('inserted row: $id');
}

_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
