import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:messenger/screens/all_users_screen.dart';
import 'package:messenger/screens/profile_screen.dart';
import 'package:messenger/screens/settings_screen.dart';
import 'package:messenger/screens/welcome_screen.dart';
import 'package:messenger/screens/friends.dart';
import 'package:messenger/screens/requests_screen.dart';

FirebaseUser loggedInUser;
final _auth = FirebaseAuth.instance;
Firestore _firestore = Firestore.instance;

class MainScreen extends StatefulWidget {
  static const String id = 'main_screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  Future initialise() async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        var title = message['notification']['title'];
        var body = message['notification']['body'];
        var fromUid = message['data']['uid'];
        // print('onMessage: $message');

        _showNotification(title, body, fromUid);
      },
      onLaunch: (Map<String, dynamic> message) async {
        // print('onMessage: $message');
        _serialiseAndNavigate(message);
      },
      onResume: (Map<String, dynamic> message) async {
        // print('onMessage: $message');
        _serialiseAndNavigate(message);
      },
    );
  }

  void _serialiseAndNavigate(Map<String, dynamic> message) {
    var notificationData = message['data'];
    var fromUid = notificationData['uid'];

    if (fromUid != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => new ProfileScreen(fromUid),
        ),
      );
    }
  }

  Future<void> _showNotification(
      String title, String body, String fromUid) async {
    var androidPlatformChannelSpecfics = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'test ticker');
    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecfics, iOSChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: fromUid);
  }

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

  _saveDeviceToken() async {
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      await _firestore
          .collection('Users')
          .document(loggedInUser.uid)
          .updateData({'token': fcmToken});
    }
  }

  void appBarMenuHandler(String selectedItem) {
    switch (selectedItem) {
      case 'Logout':
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
        break;
      case 'Account Settings':
        Navigator.pushNamed(context, SettingsScreen.id);
        break;
      case 'All Users':
        Navigator.pushNamed(context, AllUsersScreen.id);
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    getCurrentUser();
    _saveDeviceToken();
    initialise();
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => new ProfileScreen(payload),
      ),
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('ok'),
                  onPressed: () {
                    Navigator.popAndPushNamed(context, ProfileScreen.id);
                  },
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Messenger'),
            backgroundColor: Colors.indigo,
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (selectedItem) {
                  appBarMenuHandler(selectedItem);
                },
                itemBuilder: (BuildContext context) {
                  return {
                    'Account Settings',
                    'All Users',
                    'Logout',
                  }.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(text: 'REQUESTS'),
                Tab(text: 'CHATS'),
                Tab(text: 'FRIENDS'),
              ],
            ),
          ),
          body: TabBarView(children: [
            Container(
              child: Center(
                child: Scaffold(
                  body: RequestsScreen(loggedInUser),
                ),
              ),
            ),
            //Chat Screen
            Container(
              child: Center(
                child: Text(
                  'Chats',
                  style: TextStyle(
                    fontFamily: 'raleway',
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
            Container(
              child: Center(
                child: Scaffold(
                  body: FriendsList(loggedInUser),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
