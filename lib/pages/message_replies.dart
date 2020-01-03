import 'package:flutter/material.dart';

final messages = [
  [
    MessageViewModel(
      Column(
        children: <Widget>[
          Text(
            "Hey there, \nBot is initializing.",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'FlamanteRoma',
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    ),
  ]
];

class MessageReply extends StatelessWidget {
  final List<MessageViewModel> viewModels;
  final double percentVisible;

  MessageReply({
    this.viewModels,
    this.percentVisible = 1.0,
  });

  List<Widget> _generatePage(List<MessageViewModel> modelList){
    List<Widget> pagebody = [];
    for (var model in modelList) {
      pagebody.add(model.body);
    }
    return pagebody;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        color: Colors.white10,
        child: Opacity(
          opacity: percentVisible,
          child: Padding(
            padding: const EdgeInsets.only(top: 200),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Transform(
                transform: Matrix4.translationValues(
                    0.0, 50.0 * (1.0 - percentVisible), 0.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: _generatePage(viewModels),
                  ),
                ),
              ),
            ]),
          ),
        ));
  }
}

class MessageViewModel {
  final Widget body;

  MessageViewModel(this.body);
}
