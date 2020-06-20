import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:messenger/components/rounded_button.dart';
import 'package:messenger/screens/login_screen.dart';
import 'package:messenger/screens/registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: 'hero',
                      child: SvgPicture.asset(
                        'images/splash.svg',
                        height: 60.0,
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text(
                      'Welcome',
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
                  RoundedButton(
                    title: 'Log in',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, LoginScreen.id);
                    },
                  ),
                  RoundedButton(
                    title: 'Register',
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
}
