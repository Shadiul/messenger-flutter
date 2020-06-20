import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:messenger/screens/profile_screen.dart';
import 'package:messenger/components/user_list_card.dart';

final _fireStore = Firestore.instance;

class FriendsList extends StatefulWidget {
  static const String id = 'friends_screen';
  final FirebaseUser user;
  FriendsList(this.user);
  @override
  _FriendsListState createState() => _FriendsListState(user);
}

class _FriendsListState extends State<FriendsList> {
  final FirebaseUser user;
  _FriendsListState(this.user);

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

          final friends = snapshot.data.documents;

          List<FriendsCard> friendsCards = [];

          for (var friend in friends) {
            final uid = friend.documentID;
            final friendsCard = FriendsCard(uid);
            friendsCards.add(friendsCard);
          }
          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: friendsCards,
            ),
          );
        });
  }
}

class FriendsCard extends StatelessWidget {
  final String uid;
  FriendsCard(this.uid);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _fireStore.collection('Users').document(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center();
        }
        final user = snapshot.data;

        final userName = user['name'];
        final profileImage = user['profile'];
        final status = user['status'];
        final uid = user['user_id'];

        return UserListCard(
          userName: userName,
          profileImage: profileImage,
          status: status,
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
