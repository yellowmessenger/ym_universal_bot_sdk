import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'pager_indicator.dart';

class PageDragger extends StatefulWidget {
  final bool canDragLeftToRight;
  final bool canDragRightToLeft;
  final bool canDragTopToBottom;
  final bool canDragBottomToTop;
  final StreamController<SlideUpdate> slideUpdateStream;

  PageDragger({
    this.canDragLeftToRight,
    this.canDragRightToLeft,
    this.canDragBottomToTop,
    this.canDragTopToBottom,
    this.slideUpdateStream,
  });

  @override
  _PageDraggerState createState() => new _PageDraggerState();
}

class _PageDraggerState extends State<PageDragger> {
  static const FULL_TRANSITION_PX = 300.0;

  Offset dragStart;
  SlideDirection slideDirection;
  double slidePercent = 0.0;

  onDragStart(DragStartDetails details) {
    dragStart = details.globalPosition;
  }

  onDragUpdate(DragUpdateDetails details) {
    if (dragStart != null) {
      final newPosition = details.globalPosition;
      final dy = dragStart.dy - newPosition.dy;
       if (dy > 0.0 && widget.canDragBottomToTop) {
        slideDirection = SlideDirection.bottomToTop;
      } else if (dy < 0.0 && widget.canDragTopToBottom) {
        slideDirection = SlideDirection.topToBottom;
      } 
      else {
        slideDirection = SlideDirection.none;
      }

      if (slideDirection != SlideDirection.none) {
        slidePercent = (dy / FULL_TRANSITION_PX).abs().clamp(0.0, 1.0);
      } else {
        slidePercent = 0.0;
      }

      widget.slideUpdateStream.add(
          new SlideUpdate(UpdateType.dragging, slideDirection, slidePercent));
    }
  }

  onDragEnd(DragEndDetails details) {
    widget.slideUpdateStream.add(new SlideUpdate(
      UpdateType.doneDragging,
      SlideDirection.none,
      0.0,
    ));

    dragStart = null;
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDragUpdate,
      onHorizontalDragEnd: onDragEnd,
    );
  }
}

class AnimatedPageDragger {
  static const PERCENT_PER_MILLISECOND = 0.005;

  final slideDirection;
  final transitionGoal;

  AnimationController completionAnimationController;

  AnimatedPageDragger({
    this.slideDirection,
    this.transitionGoal,
    slidePercent,
    StreamController<SlideUpdate> slideUpdateStream,
    TickerProvider vsync,
  }) {
    final startSlidePercent = slidePercent;
    var endSlidePercent;
    var duration;

    if (transitionGoal == TransitionGoal.open) {
      endSlidePercent = 1.0;
      final slideRemaining = 1.0 - slidePercent;
      duration = new Duration(
          milliseconds: (slideRemaining / PERCENT_PER_MILLISECOND).round());
    } else {
      endSlidePercent = 0.0;
      duration = new Duration(
          milliseconds: (slidePercent / PERCENT_PER_MILLISECOND).round());
    }

    completionAnimationController =
        new AnimationController(duration: duration, vsync: vsync)
          ..addListener(() {
            slidePercent = lerpDouble(
              startSlidePercent,
              endSlidePercent,
              completionAnimationController.value,
            );

            slideUpdateStream.add(new SlideUpdate(
              UpdateType.animating,
              slideDirection,
              slidePercent,
            ));
          })
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              slideUpdateStream.add(new SlideUpdate(
                UpdateType.doneAnimating,
                slideDirection,
                endSlidePercent,
              ));
            }
          });
  }

  run() {
    completionAnimationController.forward(from: 0.0);
  }

  dispose() {
    completionAnimationController.dispose();
  }
}

enum TransitionGoal {
  open,
  close,
}

enum UpdateType {
  dragging,
  doneDragging,
  animating,
  doneAnimating,
}

class SlideUpdate {
  final updateType;
  final direction;
  final slidePercent;

  SlideUpdate(
    this.updateType,
    this.direction,
    this.slidePercent,
  );
}
