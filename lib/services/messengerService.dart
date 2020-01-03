
import 'package:flutter_xmpp/flutter_xmpp.dart';

class MessengerService{
  
  static Future<String> sendMessage(String msgBody) async {
  String msg = await FlutterXmpp.sendMessage(msgBody);
  return msg;
}
}