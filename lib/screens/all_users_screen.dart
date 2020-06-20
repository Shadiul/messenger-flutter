import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/screens/profile_screen.dart';

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;

class AllUsersScreen extends StatefulWidget {
  static const String id = 'all_users_screen';
  @override
  _AllUsersScreenState createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {
  final _auth = FirebaseAuth.instance;

  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[UsersStream()],
          ),
        ),
      ),
    );
  }
}

class UsersStream extends StatelessWidget {
  const UsersStream({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final users = snapshot.data.documents;
          List<UserCard> userCards = [];
          for (var user in users) {
            final userName = user.data['name'];
            final profileImage = user.data['profile'];
            final status = user.data['status'];
            final uid = user.data['user_id'];

            final userCard = UserCard(
              name: userName,
              profileImage: profileImage,
              status: status,
              uid: uid,
            );
            userCards.add(userCard);
          }
          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: userCards,
            ),
          );
        });
  }
}

class UserCard extends StatelessWidget {
  UserCard({this.name, this.profileImage, this.status, this.uid});

  final String name;
  final String profileImage;
  final String status;
  final String uid;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => new ProfileScreen(uid),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: <Widget>[
            Container(
              child: CircleAvatar(
                radius: 30.0,
                backgroundImage: profileImage == null
                    ? AssetImage('images/avatar_male.png')
                    : NetworkImage(profileImage),
              ),
            ),
            SizedBox(
              width: 15.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
