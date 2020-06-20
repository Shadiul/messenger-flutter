import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:messenger/components/rounded_button.dart';
import 'package:messenger/components/user_info.dart';
import 'package:messenger/screens/chat_screen.dart';

FirebaseUser loggedInUser;

class ProfileScreen extends StatefulWidget {
  ProfileScreen(this.uid);
  final String uid;

  static const String id = 'profile_screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState(uid);
}

class _ProfileScreenState extends State<ProfileScreen> {
  _ProfileScreenState(this.uid);
  final String uid;
  Timestamp friendSince;
  String requestType = '';
  String titleText = '';

  Firestore _firestore = Firestore.instance;

  final _auth = FirebaseAuth.instance;
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

  // UserCard args;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    // var uid = ModalRoute.of(context).settings.arguments;

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('Users').document(uid).snapshots(),
      builder: (context, sanpshot) {
        if (!sanpshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SpinKitDoubleBounce(
              color: Colors.indigo,
            ),
          );
        }
        final user = sanpshot.data;

        final profileImage = user['profile'];
        final name = user['name'];
        final status = user['status'];

        return StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('Friends')
                .document(loggedInUser.uid)
                .collection("friend")
                .document(uid)
                .snapshots(),
            builder: (context, sanpshot) {
              if (!sanpshot.hasData) {
                friendSince = null;
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: SpinKitDoubleBounce(
                    color: Colors.indigo,
                  ),
                );
              }
              final friend = sanpshot.data;

              try {
                friendSince = friend['friend_since'];
              } catch (e) {
                friendSince = null;
              }

              return StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('Requests')
                      .document(loggedInUser.uid)
                      .collection("requests")
                      .document(uid)
                      .snapshots(),
                  builder: (context, sanpshot) {
                    if (!sanpshot.hasData) {
                      requestType = 'null';
                      return Scaffold(
                        backgroundColor: Colors.white,
                        body: SpinKitDoubleBounce(
                          color: Colors.indigo,
                        ),
                      );
                    }
                    final request = sanpshot.data;

                    try {
                      requestType = request['req_type'];
                    } catch (e) {
                      requestType = null;
                    }

                    if (friendSince == null) {
                      if (requestType == null) {
                        titleText = 'Add Friend';
                      }
                      if (requestType == 'sent') {
                        titleText = 'Cancel Request';
                      } else if (requestType == 'received') {
                        titleText = 'Accept Request';
                      }
                    } else if (friendSince != null) {
                      titleText = 'Remove Friend';
                    }

                    return Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.indigo,
                      ),
                      body: SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 30.0,
                              ),
                              UserInformation(
                                color: Colors.black87,
                                profileImageUrl: profileImage,
                                status: status,
                                username: name,
                                uid: uid,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    RoundedButton(
                                      title: titleText,
                                      onPressed: loggedInUser.uid == uid
                                          ? null
                                          : () async {
                                              if (titleText == 'Add Friend') {
                                                _firestore
                                                    .collection('Requests')
                                                    .document(loggedInUser.uid)
                                                    .collection("requests")
                                                    .document(uid)
                                                    .setData(
                                                        {'req_type': 'sent'});
                                                _firestore
                                                    .collection('Requests')
                                                    .document(uid)
                                                    .collection("requests")
                                                    .document(loggedInUser.uid)
                                                    .setData({
                                                  'req_type': 'received'
                                                });

                                                _firestore
                                                    .collection('Notifications')
                                                    .document(uid)
                                                    .collection('notifications')
                                                    .add({
                                                  'from_name':
                                                      loggedInUser.displayName,
                                                  'from_uid': loggedInUser.uid,
                                                  'type': 'request',
                                                });
                                              } else if (titleText ==
                                                  'Accept Request') {
                                                _firestore
                                                    .collection('Friends')
                                                    .document(loggedInUser.uid)
                                                    .collection("friend")
                                                    .document(uid)
                                                    .setData({
                                                  'friend_since': DateTime.now()
                                                });
                                                _firestore
                                                    .collection('Friends')
                                                    .document(uid)
                                                    .collection("friend")
                                                    .document(loggedInUser.uid)
                                                    .setData({
                                                  'friend_since': DateTime.now()
                                                });
                                                _firestore
                                                    .collection('Requests')
                                                    .document(loggedInUser.uid)
                                                    .collection("requests")
                                                    .document(uid)
                                                    .delete();
                                                _firestore
                                                    .collection('Requests')
                                                    .document(uid)
                                                    .collection("requests")
                                                    .document(loggedInUser.uid)
                                                    .delete();
                                              } else if (titleText ==
                                                  'Cancel Request') {
                                                _firestore
                                                    .collection('Requests')
                                                    .document(loggedInUser.uid)
                                                    .collection("requests")
                                                    .document(uid)
                                                    .delete();
                                                _firestore
                                                    .collection('Requests')
                                                    .document(uid)
                                                    .collection("requests")
                                                    .document(loggedInUser.uid)
                                                    .delete();
                                              } else if (titleText ==
                                                  'Remove Friend') {
                                                _firestore
                                                    .collection('Friends')
                                                    .document(loggedInUser.uid)
                                                    .collection("friend")
                                                    .document(uid)
                                                    .delete();

                                                _firestore
                                                    .collection('Friends')
                                                    .document(uid)
                                                    .collection("friend")
                                                    .document(loggedInUser.uid)
                                                    .delete();
                                              }
                                            },
                                      color: Colors.deepOrange,
                                    ),
                                    RoundedButton(
                                      title: 'Message',
                                      onPressed: loggedInUser.uid == uid
                                          ? null
                                          : () {
                                              // await statusUpdateDialog(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      new ChatScreen(uid),
                                                ),
                                              );
                                            },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            });
      },
    );
  }
}
