import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:messenger/components/rounded_button.dart';
import 'package:messenger/screens/main_screen.dart';
import 'package:messenger/screens/welcome_screen.dart';

FirebaseUser loggedInUser;

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = FirebaseAuth.instance;

  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });

        Navigator.pushReplacementNamed(context, MainScreen.id);
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Hero(
                  tag: 'hero',
                  child: SvgPicture.asset(
                    'images/splash.svg',
                    height: 200.0,
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Text(
                  'Messenger',
                  style: TextStyle(
                    fontSize: 24.0,
                    letterSpacing: 3,
                    fontFamily: 'Raleway',
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Team Creatic',
                  style: TextStyle(
                    fontSize: 14.0,
                    letterSpacing: 3,
                    fontFamily: 'Raleway',
                  ),
                ),
              ],
            ),
            RoundedButton(
              title: 'Start',
              onPressed: () {
                Navigator.pushReplacementNamed(context, WelcomeScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
