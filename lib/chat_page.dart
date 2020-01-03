import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_xmpp/flutter_xmpp.dart';
import 'package:ym_universal_bot_sdk/models/configMap.dart';

import 'common/bubble.dart';
import 'common/topbar.dart';
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
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  bool ready = false;
  StreamSubscription chatStreamSubscription;
  List<Widget> suggestions = [];
  ConfigMap configMap;


   _getConfigurations() async{
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

      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
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
                  refresh(option.text);
                } else if (option.url != null && option.url != '') {
                  _launchURL(option.url);
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
    // requestPermission();
    initSpeechRecognizer();
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

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => _textEditingController.text = speech),
      // (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      (String speech) => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  @override
  Widget build(BuildContext context) {
    maxWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final logoHeight = screenHeight * 0.5;
    return Scaffold(
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
            Padding(
              padding: const EdgeInsets.only(top: 45),
              child: Column(
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
                        children: suggestions,
                      ),
                    ),
                  ),
                  Divider(height: 4.0),
                  Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).cardColor),
                    child: _messageEditor(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
              child: TopBar(configMap.botIcon),
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

_sendFromKeyboard(){
  if(_textEditingController.text.isNotEmpty)
   _textMessageSubmitted(_textEditingController.text);
}

  RaisedButton _getDefaultSendButton() {
    return RaisedButton(
      color: Colors.blue,
      shape: CircleBorder(),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : () {
              if (_isAvailable && !_isListening) {
                _speechRecognition.listen(locale: "en_US").then((result) {
                  _textEditingController.text = resultText;
                  _isComposingMessage = true;
                });
              }
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
    if (_isListening)
      _speechRecognition.stop().then((onValue) {
        _speechRecognition
            .activate()
            .then((result) => setState(() => _isAvailable = result));
      });
    DateTime now = DateTime.now();
    var queueMessage =
        Message(text, DateFormat('kk:mm').format(now), true, true);
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

  refresh(String message) {
    _textMessageSubmitted(message);
    suggestions.clear();
  }
}

Future<String> sendMessage(String msgBody) async {
  String msg = await FlutterXmpp.sendMessage(msgBody);
  return msg;
}

// Setting/Requesting permissions at run time
// requestPermission() async {
//   final res =
//       await Permission.requestSinglePermission(PermissionName.Microphone);
//   final res2 = await Permission.requestSinglePermission(PermissionName.Phone);
//   print(res);
//   print(res2);
// }

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

//To remove after testing
_clearTable() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  await helper.clearTable();
  print('deleted Table');
}

_launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
