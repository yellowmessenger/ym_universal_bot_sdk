import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:ym_universal_bot_sdk/services/messengerService.dart';

import '../services/url_launcher.dart';
import '../models/cards.dart';
import '../models/quick_replies.dart';
import '../models/Message.dart';
import '../models/cards.dart' as cardModel;


class ResponseCreator {
  
  static Widget createResponseItem(Message msg, [BuildContext context]) {
    Widget responseWidget = Container();
    switch(msg.format){
      case MessageFormats.Text : 
      responseWidget = Column(
      children: <Widget>[
        Text(
          msg.message,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: 'FlamanteRoma',
            fontSize: 20.0,
          ),
        ),
      ],
    );
      break;
      case MessageFormats.QuickReplies : 
      responseWidget = Column(
      children: <Widget>[
        Text(
          "Quick Replies",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: 'FlamanteRoma',
            fontSize: 20.0,
          ),
        ),
      ],
    );
      break;
      case MessageFormats.Image : 
      responseWidget = Column(
      children: <Widget>[
        Text(
          "Image Message",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: 'FlamanteRoma',
            fontSize: 20.0,
          ),
        ),
      ],
    );
      break;
      case MessageFormats.Video : 
      responseWidget = Column(
      children: <Widget>[
        Text(
          "Video Message",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: 'FlamanteRoma',
            fontSize: 20.0,
          ),
        ),
      ],
    );
      break;
      case MessageFormats.CardsResponse : 

responseWidget = Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: createCards(msg.cards)),
          ),
        );
      break;
      default : 
    }
    return responseWidget;
  }

  static Widget create(String data, [BuildContext context]) {
    Widget responseWidget = Container();
    DateTime now = DateTime.now();
    try{
      var replyText = json.decode(data);
      print("******************");
      print(replyText['journeyName']);
      print("******************");
      if (replyText['message'] != null) {
        responseWidget = createResponseItem(Message(replyText['message'],
            DateFormat('kk:mm').format(now), true, false));
      } else if (replyText['quickReplies'] != null) {
        QuickReplies quickReplies =
            QuickReplies.fromJson(replyText['quickReplies']);
        responseWidget = createResponseItem(Message(
            quickReplies.title, DateFormat('kk:mm').format(now), true, false,
            format: MessageFormats.QuickReplies,
            quickReplies: quickReplies.options));
      } else if (replyText['image'] != null) {
        responseWidget = createResponseItem(Message(
            replyText['image'], DateFormat('kk:mm').format(now), true, false,
            format: MessageFormats.Image));
      } else if (replyText['video'] != null) {
        responseWidget = createResponseItem(Message(replyText['video']['url'],
            DateFormat('kk:mm').format(now), true, false,
            format: MessageFormats.Video));
      } else if (replyText['cards'] != null) {
        CardResponse cards = CardResponse.fromJson(replyText);
        responseWidget = createResponseItem(Message(
            '', DateFormat('kk:mm').format(now), true, false,
            format: MessageFormats.CardsResponse, cards: cards), context);
      }

    return responseWidget;
    }
    catch (e){

    }
    finally{
    return responseWidget;
    }

  }

  static String getJourneySlug(String data){
    String journeySlug = '';
    try{
      var replyText = json.decode(data);
      if(replyText['journeySlug'] != null){
        journeySlug = replyText['journeySlug'];
      }

      }
      catch(e){

      }
    return journeySlug;
  }

    static List<Widget> createCards(CardResponse cards) {
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

    static List<Widget> _createActions(List<cardModel.Actions> actions) {
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
            MessengerService.sendMessage(action.text);
            // widget.notifyParent(action.text);
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
}
