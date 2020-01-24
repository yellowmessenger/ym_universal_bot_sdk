import 'package:flutter/services.dart';

class BotConfigService{

 static Future<String> loadAsset() async {
  var content = await rootBundle.loadString('config/botConfig_mg.json');
  return content;
}
}