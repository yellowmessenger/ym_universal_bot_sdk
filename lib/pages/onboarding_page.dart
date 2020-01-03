import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_xmpp/bot_config.dart';
import 'package:flutter_xmpp/flutter_xmpp.dart';
import 'package:ym_universal_bot_sdk/services/botConfigService.dart';
import 'page_dragger.dart';
import 'page_reveal.dart';
import 'pager_indicator.dart';
import 'pages.dart';

class OnboardingPage extends StatefulWidget {
  final Stream<String> chatStream;
  OnboardingPage(this.chatStream);

  @override
  _OnboardingPageState createState() => new _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  StreamController<SlideUpdate> slideUpdateStream;
  AnimatedPageDragger animatedPageDragger;

  int activeIndex = 0;
  int nextPageIndex = 0;
  SlideDirection slideDirection = SlideDirection.none;
  double slidePercent = 0.0;

  _OnboardingPageState() {
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _enableStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Page(
            stream: widget.chatStream,
            viewModel: pages[activeIndex],
            percentVisible: 1.0,
          ),
          PageReveal(
            revealPercent: slidePercent,
            child: Page(
              stream: widget.chatStream,
              viewModel: pages[nextPageIndex],
              percentVisible: slidePercent,
            ),
          ),
          PageDragger(
            canDragTopToBottom: activeIndex > 0,
            canDragBottomToTop: activeIndex < pages.length - 1,
            slideUpdateStream: this.slideUpdateStream,
          ),
        ],
      ),
    );
  }
}
