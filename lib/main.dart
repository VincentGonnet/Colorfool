import 'dart:io' show Platform;

import 'package:colorfool/views/login_view.dart';
import 'package:colorfool/views/register_view.dart';
import 'package:colorfool/views/verify_email_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
                if (user.emailVerified) {
                  print("Email verified");
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }
              return const Text("Done");
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

