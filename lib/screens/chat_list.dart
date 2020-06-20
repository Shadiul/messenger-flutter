import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:messenger/components/user_list_card.dart';
import 'package:messenger/screens/chat_screen.dart';

final _firestore = Firestore.instance;
var _database = FirebaseDatabase();
FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser loggedInUser;

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
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
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          loggedInUser != null
              ? ConversationsStream()
              : Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SpinKitDoubleBounce(
                        color: Colors.indigo,
                      ),
                    ],
                  ),
                ),
          // Expanded(
          //   child: Center(),
          // ),
        ],
      ),
    );
  }
}

class ConversationsStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Messages')
          .document(loggedInUser.uid)
          .collection('Conversations')
          .orderBy('timestamp', descending: true)
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

        print(snapshot.data.documents);

        _database
            .reference()
            .child('Users')
            .child(loggedInUser.uid)
            .onDisconnect()
            .set({'active': false});
        _database
            .reference()
            .child('Users')
            .child(loggedInUser.uid)
            .set({'active': true});

        final conversations = snapshot.data.documents;

        List<ConversationsCard> conversationsCards = [];

        for (var conversation in conversations) {
          final uid = conversation.documentID;
          final lastMessage = conversation.data['last message'];

          final conversationCard = ConversationsCard(uid, lastMessage);
          conversationsCards.add(conversationCard);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
            children: conversationsCards,
          ),
        );
      },
    );
  }
}

class ConversationsCard extends StatefulWidget {
  ConversationsCard(this.uid, this.lastMessage);
  final String uid;
  final String lastMessage;
  @override
  _ConversationsCardState createState() => _ConversationsCardState();
}

class _ConversationsCardState extends State<ConversationsCard> {
  bool active;
  void checkActive(uid) {
    _database
        .reference()
        .child('Users')
        .child(uid)
        .child('active')
        .onValue
        .listen((event) {
      if (this.mounted) {
        setState(() {
          active = event.snapshot.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('Users').document(widget.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center();
        }

        final user = snapshot.data;

        final userName = user['name'];
        final profileImage = user['profile'];
        // final status = user['status'];
        final uid = user['user_id'];
        checkActive(uid);

        return UserListCard(
          userName: userName,
          profileImage: profileImage,
          status: widget.lastMessage,
          active: active,
          uid: uid,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => new ChatScreen(uid),
              ),
            );
          },
        );
      },
    );
  }
}
