import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({@required this.title, this.onPressed, this.color});

  final String title;
  final Function onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
      child: FlatButton(
        padding: EdgeInsets.all(15.0),
        color: color == null ? Colors.indigoAccent : color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        onPressed: onPressed,
        child: Container(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
