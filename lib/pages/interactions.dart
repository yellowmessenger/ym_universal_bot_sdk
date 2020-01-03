import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ym_universal_bot_sdk/services/responseCreator.dart';
import '../services/messengerService.dart';
import '../common/topbar.dart';
import 'message_replies.dart';
import '../utils/colors.dart';
import 'page_dragger.dart';
import 'page_reveal.dart';
import 'pager_indicator.dart';

class InteractionsPage extends StatefulWidget {
  final Stream<String> chatStream;
  InteractionsPage(this.chatStream);
  @override
  _InteractionsPageState createState() => new _InteractionsPageState();
}

class _InteractionsPageState extends State<InteractionsPage>
    with TickerProviderStateMixin {
  StreamController<SlideUpdate> slideUpdateStream;
  AnimatedPageDragger animatedPageDragger;
  StreamSubscription chatStreamSubscription;

  int activeIndex = 0;
  int nextPageIndex = 0;
  SlideDirection slideDirection = SlideDirection.none;
  double slidePercent = 0.0;

  _enableStream() {
    if (chatStreamSubscription == null) {
      chatStreamSubscription = widget.chatStream.listen(_updateChat);
    }
  }

  String oldSlug = '';

  void _updateChat(String data) {
    print("Some data arrived: " + data);
    String slug = ResponseCreator.getJourneySlug(data);
    if (slug != '') {
      if (oldSlug == '' || oldSlug != slug) {
        messages.add([MessageViewModel(ResponseCreator.create(data, context))]);
        setState(() {
          oldSlug = slug;
          activeIndex += 1;
        });
      } else {
        messages[messages.length - 1]
            .add(MessageViewModel(ResponseCreator.create(data)));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _enableStream();
    print("Sending Message");
    MessengerService.sendMessage("Hi");
  }

  _InteractionsPageState() {
    slideUpdateStream = new StreamController<SlideUpdate>();

    slideUpdateStream.stream.listen((SlideUpdate event) {
      setState(() {
        if (event.updateType == UpdateType.dragging) {
          //print('Sliding ${event.direction} at ${event.slidePercent}');
          slideDirection = event.direction;
          slidePercent = event.slidePercent;

          if (slideDirection == SlideDirection.topToBottom) {
            nextPageIndex = activeIndex - 1;
          } else if (slideDirection == SlideDirection.bottomToTop) {
            nextPageIndex = activeIndex + 1;
          } else {
            nextPageIndex = activeIndex;
          }
        } else if (event.updateType == UpdateType.doneDragging) {
          //print('Done dragging.');
          if (slidePercent > 0.2) {
            animatedPageDragger = new AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.open,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vsync: this,
            );
          } else {
            animatedPageDragger = new AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.close,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vsync: this,
            );

            nextPageIndex = activeIndex;
          }

          animatedPageDragger.run();
        } else if (event.updateType == UpdateType.animating) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;
        } else if (event.updateType == UpdateType.doneAnimating) {
          activeIndex = nextPageIndex;

          slideDirection = SlideDirection.none;
          slidePercent = 0.0;

          animatedPageDragger.dispose();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final logoHeight = screenHeight * 0.5;
    return Scaffold(
      body: Stack(
        children: [
          Transform.translate(
            offset: Offset(screenWidth * 0.3, 0),
            child: Transform.rotate(
              angle: -0.3,
              child: Image.asset(
                "images/logo.png",
                height: logoHeight,
                color: logoTintColor,
              ),
            ),
          ),
          PageDragger(
            canDragTopToBottom: activeIndex > 0,
            canDragBottomToTop: activeIndex < messages.length - 1,
            slideUpdateStream: this.slideUpdateStream,
          ),
          MessageReply(
            viewModels: messages[activeIndex],
            percentVisible: 1.0,
          ),
          PageReveal(
            revealPercent: slidePercent,
            child: MessageReply(
              viewModels: messages[nextPageIndex],
              percentVisible: slidePercent,
            ),
          ),
          // PageDragger(
          //   canDragTopToBottom: activeIndex > 0,
          //   canDragBottomToTop: activeIndex < messages.length - 1,
          //   slideUpdateStream: this.slideUpdateStream,
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
            child: TopBar(''),
          ),
        ],
      ),
    );
  }
}
