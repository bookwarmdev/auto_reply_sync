library auto_reply_sync;

import 'package:flutter/material.dart';

/// A Calculator.
// class Calculator {
//   /// Returns [value] plus 1.
//   int addOne(int value) => value + 1;
// }

class ReponsiveRowColumn extends StatefulWidget {
  final Widget widget1;
  final Widget widget2;
  final Widget widget3;

  const ReponsiveRowColumn({
    super.key,
    required this.widget1,
    required this.widget2,
    required this.widget3,
  });

  @override
  State<ReponsiveRowColumn> createState() => _ReponsiveRowColumnState();
}

class _ReponsiveRowColumnState extends State<ReponsiveRowColumn> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              widget.widget1,
              widget.widget2,
              widget.widget3,
            ],
          );
        } else {
          return Row(
            children: [
              widget.widget1,
              widget.widget2,
              widget.widget3,
            ],
          );
        }
      },
    );
  }
}
