import 'dart:io' show Platform;

import 'package:colorfool/constants/routes.dart';
import 'package:colorfool/views/colors_view.dart';
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
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        colorsRoute: (context) => const ColorsView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<FirebaseApp> _initializeFirebase() {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        return Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAGCQOM5y0sdl3LNKmCqejYQBHniV4JH3U',
            appId: '1:331560952012:android:a98d2f37f46a0b24cf6269',
            messagingSenderId: '331560952012',
            projectId: 'colorfool',
          ),
        );
      } else {
        return Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      }
    } else {
      return Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }

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
                  print(user);
                  return const VerifyEmailView();
                }
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