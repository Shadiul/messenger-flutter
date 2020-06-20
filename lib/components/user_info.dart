import 'package:flutter/material.dart';

class UserInformation extends StatelessWidget {
  const UserInformation(
      {this.profileImageUrl, this.status, this.username, this.color});

  final String username;
  final String status;
  final String profileImageUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CircleAvatar(
          radius: 100.0,
          backgroundImage: profileImageUrl == null
              ? AssetImage('images/avatar_male.png')
              : NetworkImage(profileImageUrl),
        ),
        SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            username,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'raleway',
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 5.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'raleway',
              fontSize: 16.0,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
