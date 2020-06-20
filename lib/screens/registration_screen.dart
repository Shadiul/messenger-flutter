import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:messenger/components/rounded_button.dart';
import 'package:messenger/screens/login_screen.dart';
import 'package:messenger/screens/main_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;
  UserUpdateInfo _updateInfo = UserUpdateInfo();
  String _email = '';
  String _password = '';
  String _displayName = '';
  String _uid = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Registration',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.bold,
                        fontSize: 40.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 5.0),
                    child: TextField(
                      onChanged: (value) {
                        _displayName = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Display Name',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 5.0),
                    child: TextField(
                      onChanged: (value) {
                        _email = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 5.0),
                    child: TextField(
                      onChanged: (value) {
                        _password = value;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  RoundedButton(
                    title: 'Register',
                    onPressed: () async {
                      if (_displayName != '') {
                        try {
                          await _auth
                              .createUserWithEmailAndPassword(
                                  email: _email, password: _password)
                              .then((value) {
                            _updateInfo.displayName = _displayName;
                            value.user.updateProfile(_updateInfo);
                          });
                          FirebaseUser currentUser =
                              await FirebaseAuth.instance.currentUser();
                          _uid = currentUser.uid;

                          _firestore
                              .collection('Users')
                              .document(_uid)
                              .setData({
                            'name': _displayName,
                            'email': _email,
                            'password': _password,
                            'status': 'No status is recorded.',
                            'time_created': DateTime.now(),
                            'user_id': _uid,
                          });

                          Navigator.pushReplacementNamed(
                              context, MainScreen.id);
                        } on PlatformException catch (e) {
                          print(e);
                          switch (e.code) {
                            case 'ERROR_EMAIL_ALREADY_IN_USE':
                              errorToast('Email exists!');
                              break;
                            case 'ERROR_INVALID_EMAIL':
                              errorToast('Invalid Email address.');
                              break;
                            case 'ERROR_WEAK_PASSWORD':
                              errorToast(
                                  'Password should be at least 6 characters.');
                              break;
                            default:
                              errorToast('An error occured!');
                              break;
                          }
                        }
                      } else {
                        errorToast('Enter a display name.');
                      }
                    },
                  ),
                  RoundedButton(
                    title: 'Login',
                    color: Colors.grey,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, LoginScreen.id);
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

  void errorToast(String msg) => Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
