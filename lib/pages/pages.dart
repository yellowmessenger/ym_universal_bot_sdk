import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'interactions.dart';

final pages = [
  PageViewModel(
    PrimaryColor,
      'images/bot_icon.gif',
      'Hi there',
      'I\'m Dominos Bot. How can I help you today?',
  ),
];

class Page extends StatelessWidget {
  final PageViewModel viewModel;
  final double percentVisible;
  Stream<String> stream;

  Page({
    this.viewModel,
    this.percentVisible = 1.0, 
    this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return  Container(
        width: double.infinity,
        color: viewModel.color,
        child:  Opacity(
          opacity: percentVisible,
          child:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Transform(
                  transform:  Matrix4.translationValues(
                      0.0, 50.0 * (1.0 - percentVisible), 0.0),
                  child:  Padding(
                    padding:  EdgeInsets.only(bottom: 25.0),
                    child:  Image.asset(viewModel.heroAssetPath,
                        width: 150.0, height: 150.0),
                  ),
                ),
                 Transform(
                  transform:  Matrix4.translationValues(
                      0.0, 30.0 * (1.0 - percentVisible), 0.0),
                  child:  Padding(
                    padding:  EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child:  Text(
                      viewModel.title,
                      textAlign: TextAlign.center,
                      style:  TextStyle(
                        color: Colors.white,
                        fontFamily: 'FlamanteRoma',
                        fontSize: 34.0,
                      ),
                    ),
                  ),
                ),
                 Transform(
                  transform:  Matrix4.translationValues(
                      0.0, 30.0 * (1.0 - percentVisible), 0.0),
                  child:  Padding(
                    padding:  EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 75.0),
                    child: Column(
                      children: <Widget>[
                         Text(
                          viewModel.body,
                          textAlign: TextAlign.center,
                          style:  TextStyle(
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
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InteractionsPage(stream)));
                            },
                            child:  Text(
                              "Let's Start",
                              style:  TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ]),
        ));
  }
}

class PageViewModel {
  final Color color;
  final String heroAssetPath;
  final String title;
  final String body;

  PageViewModel(
    this.color,
    this.heroAssetPath,
    this.title,
    this.body,
  );
}
