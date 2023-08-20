library auto_reply_sync;

import 'package:flutter/material.dart';

/// A Calculator.
// class Calculator {
//   /// Returns [value] plus 1.
//   int addOne(int value) => value + 1;
// }

class ReponsiveRowColumn extends StatefulWidget {
  const ReponsiveRowColumn({super.key});

  @override
  State<ReponsiveRowColumn> createState() => _ReponsiveRowColumnState();
}

class _ReponsiveRowColumnState extends State<ReponsiveRowColumn> {
  
  late final Widget widget1;
  late final Widget widget2;
  late final Widget widget3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              widget1,
              widget2,
              widget3,
            ],
          );
        } else {
          return Row(
            children: [
              widget1,
              widget2,
              widget3,
            ],
          );
        }
      },
    );
  }
}
