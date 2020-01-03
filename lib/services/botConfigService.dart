import 'package:flutter/services.dart';

class BotConfigService{

 static Future<String> loadAsset() async {
  var content = await rootBundle.loadString('config/botConfig_Dominos.json');
  return content;
}
}