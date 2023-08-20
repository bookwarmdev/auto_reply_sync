import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ReponsiveRowColumn(
      widget1: Container(
        width: 100,
        height: 100,
        color: Colors.red,
      ),
      widget2: Container(
        width: 100,
        height: 100,
        color: Colors.black,
      ),
      widget3: Container(
        width: 100,
        height: 100,
        color: Colors.blue,
      ),
    );
  }
}
