import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Firestore _firestore = Firestore.instance;
FirebaseUser loggedInUser;
FirebaseAuth _auth = FirebaseAuth.instance;
var _firebaseRef = FirebaseDatabase();
String receiverName = '';
String receiverAvatar;

final messageTextController = TextEditingController();
String messageText;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  final String receiverID;
  ChatScreen(this.receiverID);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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

  Future<void> getCurrentReceiver() async {
    _firestore
        .collection('Users')
        .document(widget.receiverID)
        .get()
        .then((snapshot) {
      setState(() {
        receiverName = snapshot.data['name'];
        receiverAvatar = snapshot.data['profile'];
      });
    });
  }

  bool active;
  void checkActive(uid) {
    _firebaseRef
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
  void initState() {
    super.initState();
    getCurrentUser();
    getCurrentReceiver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(receiverName),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Hero(
              tag: widget.receiverID,
              child: CircleAvatar(
                backgroundColor: active != null && active
                    ? Colors.green.shade400
                    : Colors.grey,
                radius: 25.0,
                child: CircleAvatar(
                  radius: active != null && active ? 22.0 : 25.0,
                  backgroundImage: receiverAvatar != null
                      ? NetworkImage(receiverAvatar)
                      : AssetImage('images/avatar_male.png'),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Messages')
                  .document(loggedInUser.uid)
                  .collection('Conversations')
                  .document(widget.receiverID)
                  .collection('messages')
                  .orderBy('timestamp')
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
                // checkActive(widget.receiverID);
                final messages = snapshot.data.documents.reversed;
                List<MessageBubble> messageBubbles = [];
                for (var message in messages) {
                  final messageText = message.data['text'];
                  final senderName = message.data['sender name'];
                  final senderID = message.data['sender id'];
                  final currentUser = loggedInUser.uid;

                  final messageBubble = MessageBubble(
                    text: messageText,
                    sender: senderName,
                    isMe: currentUser == senderID,
                  );
                  messageBubbles.add(messageBubble);
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    children: messageBubbles,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    // wrap your Column in Expanded
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: new ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 200.0,
                            ),
                            child: new Scrollbar(
                              child: new SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                reverse: true,
                                child: new TextField(
                                  controller: messageTextController,
                                  maxLines: null,
                                  decoration:
                                      InputDecoration(hintText: 'Message'),
                                  onChanged: (value) {
                                    messageText = value;
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      messageTextController.clear();
                      if (messageText != null) {
                        _firestore
                            .collection('Messages')
                            .document(loggedInUser.uid)
                            .collection('Conversations')
                            .document(widget.receiverID)
                            .collection('messages')
                            .add({
                          'text': messageText,
                          'sender name': loggedInUser.displayName,
                          'sender id': loggedInUser.uid,
                          'timestamp': FieldValue.serverTimestamp()
                        });
                        _firestore
                            .collection('Messages')
                            .document(widget.receiverID)
                            .collection('Conversations')
                            .document(loggedInUser.uid)
                            .collection('messages')
                            .add({
                          'text': messageText,
                          'sender name': loggedInUser.displayName,
                          'sender id': loggedInUser.uid,
                          'timestamp': FieldValue.serverTimestamp()
                        });
                        _firestore
                            .collection('Messages')
                            .document(loggedInUser.uid)
                            .collection('Conversations')
                            .document(widget.receiverID)
                            .setData({
                          'timestamp': FieldValue.serverTimestamp(),
                          'last message': messageText,
                        });
                        _firestore
                            .collection('Messages')
                            .document(widget.receiverID)
                            .collection('Conversations')
                            .document(loggedInUser.uid)
                            .setData({
                          'timestamp': FieldValue.serverTimestamp(),
                          'last message': messageText,
                        });
                      }
                      messageText = null;
                    },
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

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              isMe ? '' : sender,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black,
              ),
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            elevation: 1.0,
            color: isMe ? Colors.indigo : Colors.grey.shade200,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
