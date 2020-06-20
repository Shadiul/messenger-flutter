import 'package:flutter/material.dart';

class FormTextbox extends StatelessWidget {
  const FormTextbox({this.hint, @required this.obsecureText});

  final String hint;
  final bool obsecureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
      child: TextField(
        obscureText: obsecureText,
        decoration: InputDecoration(
          hintText: hint,
        ),
      ),
    );
  }
}
