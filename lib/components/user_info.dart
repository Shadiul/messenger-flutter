import 'package:flutter/material.dart';

class UserInformation extends StatelessWidget {
  const UserInformation(
      {this.profileImageUrl, this.status, this.username, this.color, this.uid});

  final String username;
  final String status;
  final String profileImageUrl;
  final Color color;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (profileImageUrl != null) {
              expandProfileImage(context);
            }
          },
          child: Hero(
            tag: uid,
            child: CircleAvatar(
              radius: 100.0,
              backgroundImage: profileImageUrl == null
                  ? AssetImage('images/avatar_male.png')
                  : NetworkImage(profileImageUrl),
            ),
          ),
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

  Future expandProfileImage(BuildContext context) {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 50.0,
              ),
              Transform.scale(
                scale: a1.value,
                child: Opacity(
                  opacity: a1.value,
                  child: AlertDialog(
                    contentPadding: EdgeInsets.all(0),
                    content: Image(image: NetworkImage(profileImageUrl)),
                  ),
                ),
              ),
            ],
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, a1, a2) {});
  }
}
