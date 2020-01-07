import 'package:flutter/material.dart';

import './rounded_image_widget.dart';
import '../services/messengerService.dart';

class TopBar extends StatefulWidget {
  final String botIcon;
  TopBar(this.botIcon);

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
   return HeaderPanel(widget.botIcon);
  }
}

class HeaderPanel extends StatelessWidget {
  final String botIcon;
  const HeaderPanel(this.botIcon, {
    Key key,
  }) : super(key: key);

  Widget _simplePopup() => PopupMenuButton<int>(
        icon: Icon(
          Icons.translate,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("English"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("हिंदी"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("मराठी"),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: "boticon",
            child: RoundedImageWidget(imagePath: botIcon, isOnline: true)
            ),
          
          // _simplePopup(),
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => MessengerService.sendMessage('Hi'),
          )
        ],
      ),
    );
  }
}
