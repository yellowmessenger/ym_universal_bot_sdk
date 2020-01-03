
import 'package:flutter/material.dart';

class Suggestions extends StatelessWidget {
  final List<Widget> suggestions;
  Suggestions(this.suggestions);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Wrap(
          spacing: 10,
          children: suggestions,
        ),
      ),
    );
  }
}
