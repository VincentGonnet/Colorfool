import 'dart:io' show Platform;

import 'package:colorfool/views/login_view.dart';
import 'package:colorfool/views/register_view.dart';
import 'package:colorfool/views/verify_email_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colorfool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<FirebaseApp> _initializeFirebase() {
    late Future<FirebaseApp> firebaseApp;
    if (!kIsWeb) {
      if (Platform.isWindows) {
        firebaseApp = Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAGCQOM5y0sdl3LNKmCqejYQBHniV4JH3U',
            appId: '1:331560952012:android:a98d2f37f46a0b24cf6269',
            messagingSenderId: '331560952012',
            projectId: 'colorfool',
          ),
        );
      } else {
        firebaseApp = Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      }
    } else {
      firebaseApp = Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                /* if (user.emailVerified) {
                  print("Email verified");
                } else {
                  print(user);
                  return const VerifyEmailView();
                } */
              } else {
                return const LoginView();
              }
              return const ColorsView();
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

enum MenuAction { logout }

class ColorsView extends StatefulWidget {
  const ColorsView({Key? key}) : super(key: key);

  @override
  State<ColorsView> createState() => _ColorsViewState();
}

class _ColorsViewState extends State<ColorsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Colors"),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch(value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                devtools.log(shouldLogout.toString());
                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, child: Text("Logout"))
            ];
          })
        ],
      ),
      body: const Text("Hello World"),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sign out"),
          content: const Text("Are you sure you want to log out ?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Log Out")),
          ],
        );
      }).then((value) => value ?? false);
}
