import 'package:flutter/material.dart';

class UserListCard extends StatelessWidget {
  UserListCard(
      {this.onPressed,
      this.profileImage,
      this.status,
      this.userName,
      this.active});
  final Function onPressed;
  final String profileImage;
  final String userName;
  final String status;
  final bool active;

  @override
  Widget build(BuildContext context) {
    // print(active);
    return FlatButton(
      splashColor: Colors.indigo.shade100,
      padding: EdgeInsets.all(5.0),
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 35.0,
              backgroundColor: active != null && active
                  ? Colors.green.shade400
                  : Colors.grey,
              child: CircleAvatar(
                radius: active != null && active ? 30.0 : 35.0,
                backgroundImage: profileImage == null
                    ? AssetImage('images/avatar_male.png')
                    : NetworkImage(profileImage),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 8.0, bottom: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      userName,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: Text(
                      status.substring(0, status.length >= 35 ? 35 : null),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
