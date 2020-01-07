import 'dart:convert';

import 'package:intl/intl.dart';

import 'quick_replies.dart';
import 'cards.dart';

enum MessageFormats { Text, Image, Link, QuickReplies, Video, CardsResponse, MultiSelect }

class Message {
  int id;
  String message;
  String time;
  bool delivered;
  bool isMe;
  MessageFormats format;
  List<Options> quickReplies;
  List<Options> quickRepliesMulti;
  CardResponse cards;
  bool isLocalFile;

  Message(this.message, this.time, this.delivered, this.isMe,
      {this.format = MessageFormats.Text,
      this.quickReplies,
      this.isLocalFile,
      this.cards,
      this.quickRepliesMulti});

  // convenience constructor to create a Message object
  Message.fromMap(Map<String, dynamic> map) {
    id = map["_id"];
    message = map["message"];
    time = DateFormat('kk:mm').format( DateTime.parse(map["message_time"]));
    delivered = map["delivered"] == 0 ? false : true;
    isMe = map["is_me"] == 0 ? false : true;
    isLocalFile = map[isLocalFile] == 0 ? false : true;

    format =
        MessageFormats.values.firstWhere((e) => e.toString() == map["format"]);
    // quickReplies = map[quickReplies];
    // cards = map[cards];
    if (format == MessageFormats.CardsResponse) {
      //print(isMe);
      cards = CardResponse.fromJson(json.decode(map['message']));
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'message': message,
      'delivered': delivered,
      'is_me': isMe ? 1 : 0,
      'format': format == null ? MessageFormats.Text : format.toString(),
      // 'quickReplies' : quickReplies,
      // 'cards' : cards,
      'is_local_file': isLocalFile == null ? 0 : isLocalFile ? 1 : 0
    };
    if (format == MessageFormats.CardsResponse) {
      map['message'] = json.encode(cards);
    }
    if (id != null) {
      map['_id'] = id;
    }
    map['message_time'] = DateTime.now().toString();
    return map;
  }
}
