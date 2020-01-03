import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_xmpp/bot_config.dart';
import 'package:flutter_xmpp/flutter_xmpp.dart';
import 'chat_page.dart';
import 'main.dart';
import 'models/BotMapping.dart';
import 'models/configMap.dart';
import 'utils/colors.dart';
import 'utils/slide_transitions.dart';
import 'services/botConfigService.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  final Stream<String> chatStream;
  SplashPage(this.chatStream);

  @override
  _SplashPageState createState() => new _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<BotMapping> myData;
  void _enableStream() {
    BotConfigService.loadAsset().then((v) {
      var config = json.decode(v);
      BotConfig myBot =
          BotConfig(config['botId'], config['botName'], config['authToken']);
      initChannels(myBot);
    });
  }

  Future<void> initChannels(BotConfig myBot) async {
    var ready = await FlutterXmpp.initialize(myBot);
    print(ready);
    setState(() {
    myData = fetchMapping(myBot.botId);
    myData.then((val){
      print(val);
      setBotConfig(ConfigMap(
        val.data.botName,
        val.data.botTitle,
        val.data.botDesc,
        val.data.botIntro,
        val.data.botIcon,
        ));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _enableStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              width: double.infinity,
              color: PrimaryColor,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    botMappingView(),
                  ]
                  )
                  )
        ],
      ),
    );
  }

  FutureBuilder<BotMapping> botMappingView() {
    return FutureBuilder<BotMapping>(
                    future: myData,
                    builder: (BuildContext context, AsyncSnapshot<BotMapping> snapshot) {
                      List<Widget> children;

                      if (snapshot.hasData) {
                        print("I am here");
                        children = <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 25.0),
                            child: Hero(
                              tag: "boticon",
                              child: ClipOval(child: Image.network(snapshot.data.data.botIcon,
                                    width: 150.0, height: 150.0),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Text(
                              snapshot.data.data.botTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'FlamanteRoma',
                                fontSize: 34.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20.0, right: 20.0, bottom: 75.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  snapshot.data.data.botIntro == null || snapshot.data.data.botIntro == '' ? snapshot.data.data.botDesc : snapshot.data.data.botIntro,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: FlatButton(
                                    padding: const EdgeInsets.all(15.0),
                                    color: Colors.white.withOpacity(0.3),
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                          context,
                                          FadeRoute(
                                              page: ChatPage(chatStream, snapshot.data.data.skin.customHomeButtonMessage)));
                                    },
                                    child: Text(
                                      "Let's Start",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ];
                        return Column(children: children);
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      // By default, show a loading spinner.
                      return CircularProgressIndicator();
                    },
                  );
  }
}

Future<BotMapping> fetchMapping(String botId) async {
  print('https://app.yellowmessenger.com/api/plugin/mapping?bot=' +
          botId +
          '&onlyMapping=true');
  final response = await http.get(
      'https://app.yellowmessenger.com/api/plugin/mapping?bot=' +
          botId +
          '&onlyMapping=true');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    return BotMapping.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

 setBotConfig(ConfigMap configMap) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('botName', configMap.botName);
  await prefs.setString('botTitle', configMap.botTitle);
  await prefs.setString('botDesc', configMap.botDesc);
  await prefs.setString('botIntro', configMap.botIntro);
  await prefs.setString('botIcon', configMap.botIcon);
}
