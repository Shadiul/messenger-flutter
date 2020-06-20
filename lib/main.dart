import 'package:flutter/material.dart';
import 'package:messenger/screens/friends.dart';
import 'package:messenger/screens/login_screen.dart';
import 'package:messenger/screens/main_screen.dart';
import 'package:messenger/screens/profile_screen.dart';
import 'package:messenger/screens/registration_screen.dart';
import 'package:messenger/screens/settings_screen.dart';
import 'package:messenger/screens/splash_screen.dart';
import 'package:messenger/screens/start_screen.dart';
import 'package:messenger/screens/welcome_screen.dart';
import 'package:messenger/screens/all_users_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: SplashScreen.id,
        routes: {
          SplashScreen.id: (context) => SplashScreen(),
          WelcomeScreen.id: (context) => WelcomeScreen(),
          StartScreen.id: (context) => StartScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          MainScreen.id: (context) => MainScreen(),
          SettingsScreen.id: (context) => SettingsScreen(),
          AllUsersScreen.id: (context) => AllUsersScreen(),
          // ProfileScreen.id: (context) => ProfileScreen(),
        });
  }
}
