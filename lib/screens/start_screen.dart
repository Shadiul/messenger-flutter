import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';

class StartScreen extends StatefulWidget {
  static const String id = 'start_screen';
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Hello',
        style: TextStyle(color: kPrimaryColor),
      ),
    );
  }
}
