import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:messenger/components/rounded_button.dart';
import 'package:messenger/screens/main_screen.dart';
import 'package:messenger/screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _email = '';
  String _password = '';
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
                      'Log In',
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
                    title: 'Login',
                    onPressed: () async {
                      try {
                        await _auth.signInWithEmailAndPassword(
                            email: _email, password: _password);
                        Navigator.pushReplacementNamed(context, MainScreen.id);
                      } on PlatformException catch (e) {
                        print(e);
                        switch (e.code) {
                          case 'ERROR_USER_NOT_FOUND':
                            errorToast('This email is not registered!');
                            break;
                          case 'ERROR_INVALID_EMAIL':
                            errorToast('Invalid Email address.');
                            break;
                          case 'ERROR_WEAK_PASSWORD':
                            errorToast(
                                'Password should be at least 6 characters.');
                            break;
                          case 'ERROR_WRONG_PASSWORD':
                            errorToast('The password is invalid.');
                            break;
                          default:
                            errorToast('An error occured!');
                            break;
                        }
                      }
                    },
                  ),
                  RoundedButton(
                    title: 'Registration',
                    color: Colors.grey,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, RegistrationScreen.id);
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
