import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:messenger/screens/profile_screen.dart';
import 'package:messenger/components/user_list_card.dart';
import 'package:firebase_database/firebase_database.dart';

final _fireStore = Firestore.instance;
var _firebaseRef = FirebaseDatabase();

class FriendsList extends StatefulWidget {
  static const String id = 'friends_screen';
  final FirebaseUser user;
  FriendsList(this.user);
  @override
  _FriendsListState createState() => _FriendsListState(user);
}

class _FriendsListState extends State<FriendsList> {
  _FriendsListState(this.user);
  final FirebaseUser user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          UsersStream(
            loggedInUser: user,
          )
        ],
      ),
    );
  }
}

class UsersStream extends StatelessWidget {
  const UsersStream({this.loggedInUser});
  final FirebaseUser loggedInUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection('Friends')
          .document(loggedInUser.uid)
          .collection('friend')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SpinKitDoubleBounce(
                  color: Colors.indigo,
                ),
              ],
            ),
          );
        }

        _firebaseRef
            .reference()
            .child('Users')
            .child(loggedInUser.uid)
            .onDisconnect()
            .set({'active': false, 'last online': ServerValue.timestamp});
        _firebaseRef
            .reference()
            .child('Users')
            .child(loggedInUser.uid)
            .set({'active': true});

        final friends = snapshot.data.documents;

        List<String> userIds = [];

        for (var friend in friends) {
          final uid = friend.documentID;
          userIds.add(uid);
        }

        return Expanded(
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: userIds.length,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
            itemBuilder: (context, int index) {
              return FriendsCard(userIds[index]);
            },
          ),
        );
      },
    );
  }
}

class FriendsCard extends StatefulWidget {
  final String uid;
  FriendsCard(this.uid);

  @override
  _FriendsCardState createState() => _FriendsCardState();
}

class _FriendsCardState extends State<FriendsCard> {
  bool active;
  void checkActive(uid) {
    _firebaseRef
        .reference()
        .child('Users')
        .child(uid)
        .child('active')
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (mounted) {
        setState(() {
          active = dataSnapshot.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _fireStore.collection('Users').document(widget.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center();
        }

        final user = snapshot.data;

        final userName = user['name'];
        final profileImage = user['profile'];
        final status = user['status'];
        final uid = user['user_id'];

        checkActive(uid);

        return UserListCard(
          userName: userName,
          profileImage: profileImage,
          status: status,
          active: active,
          uid: uid,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => new ProfileScreen(uid),
              ),
            );
          },
        );
      },
    );
  }
}
