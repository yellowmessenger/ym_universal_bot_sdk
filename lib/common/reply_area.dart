import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:video_player/video_player.dart';
import 'package:ym_universal_bot_sdk/services/url_launcher.dart';

import '../models/cards.dart';
import '../models/quick_replies.dart';
import '../models/Message.dart';
import '../models/cards.dart' as cardModel;


class ReplyArea extends StatefulWidget {
  final Message msg;

  ReplyArea(@required this.msg);

  @override
  _ReplyAreaState createState() => _ReplyAreaState();
}

class _ReplyAreaState extends State<ReplyArea> {
  VideoPlayerController playerController;
  VoidCallback listener;
  double maxWidth = 0.0;

  @override
  void initState() {
    super.initState();
    listener = () {
      setState(() {});
    };
  }

  void createVideo(videoUrl) {
    if (playerController == null) {
      playerController = VideoPlayerController.network(videoUrl)
        ..addListener(listener)
        ..setLooping(false)
        ..initialize();
    }
  }

  Widget _messageBody() {
    Widget childElement;
    switch (widget.msg.format) {
      case MessageFormats.Text:
        childElement = Text(widget.msg.message,style: TextStyle(fontSize: 40),);
        break;
      case MessageFormats.Link:
        childElement = Text(widget.msg.message,style: TextStyle(fontSize: 40),);
        break; //todo
      case MessageFormats.QuickReplies:
        childElement = Column(
          children: _quickReplies(widget.msg.message, widget.msg.quickReplies),
        );
        break;
      case MessageFormats.CardsResponse:
        childElement = Container(
          width:  maxWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _createCards(widget.msg.cards)),
          ),
        );
        break; //todo
      case MessageFormats.Image:
        if (widget.msg.isMe && widget.msg.isLocalFile) {
          childElement = Image.file(
            File(widget.msg.message),
            height: 300,
          );
        } else {
          childElement = Image.network(
            widget.msg.message,
            height: 300,
          );
        }
        break;
      case MessageFormats.Video:
        createVideo(widget.msg.message);
        childElement = Stack(
          children: <Widget>[
            AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  child: (playerController != null
                      ? VideoPlayer(
                          playerController,
                        )
                      : Container()),
                )),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(playerController == null
                      ? Icons.hourglass_full
                      : playerController.value.isPlaying
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline),
                  color: Colors.red,
                  iconSize: 50,
                  onPressed: () {
                    if (playerController == null) {
                      createVideo(widget.msg.message);
                      playerController.play();
                    } else if (playerController.value.duration ==
                        playerController.value.position) {
                      print("Video restarting");
                      playerController.seekTo(Duration(seconds: 0));
                      playerController.play();
                    } else {
                      playerController.value.isPlaying
                          ? playerController.pause()
                          : playerController.play();
                    }
                  },
                ),
              ),
            ),
          ],
        );

        break;
      default:
        childElement = Container();
    }
    return childElement;
  }

  List<Widget> _quickReplies(String msg, List<Options> quickReplies) {
    List<Widget> suggestions = [
      Html(
        data: msg,
        defaultTextStyle: TextStyle(fontSize: 40),
      )
    ];
    return suggestions;
  }

  List<Widget> _createCards(CardResponse cards) {
    List<Widget> responseCards = [];
    for (var card in cards.cards) {
      responseCards.add(Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Container(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                card.image != null ? Image.network(card.image) : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    card.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Html(
                  data: card.text ?? '',
                  renderNewlines: true,
                ),
                card.actions != null
                    ? ListView(
                        shrinkWrap: true,
                        children: _createActions(card.actions),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ));
    }
    return responseCards;
  }

  List<Widget> _createActions(List<cardModel.Actions> actions) {
    String regexString = r'(Call\s+\()(.*?)(\))';
    RegExp regExp = new RegExp(regexString);
    List<Widget> myActions = [];
    for (var action in actions) {
      myActions.add(ListTile(
        title: Text(
          action.title,
          style: TextStyle(color: Colors.blue),
        ),
        onTap: () {
          if (action.text != null) {
//            widget.notifyParent(action.text);
          } else if (action.url != null) {
            UrlLauncher.launchURL(action.url);
          } else if (regExp.hasMatch(action.title)) {
            var match = regExp.firstMatch(action.title);
            print("tel:${match.group(2)}");
            UrlLauncher.launchURL("tel:${match.group(2)}");
          }
        },
      ));
      myActions.add(Divider(
        height: 1,
      ));
    }
    return myActions;
  }

  @override
  Widget build(BuildContext context) {
    maxWidth = MediaQuery.of(context).size.width;
    return _messageBody();
  }
}

class Reply extends StatelessWidget {
  final Message msg;

  Reply(this.msg);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      child: Text(
        msg.message ?? "Waiting...",
        style: TextStyle(fontSize: 40),
      ),
    );
  }
}

