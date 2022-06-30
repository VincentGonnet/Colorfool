import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_desktop/firebase_auth_desktop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';
import 'dart:io' show Platform;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

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
      firebaseApp = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email here.',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
                hintText: 'Enter your password here.'
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password
                );
                print(userCredential);
              } on FirebaseAuthException catch (error) {
                if (error.code == "user-not-found") {
                  print("User not found");
                } else if (error.code == "wrong-password") {
                  print("Wrong password");
                } else {
                  print(error.code);
                }
              } catch (error) {
                print("--- ERROR ---");
                print(error.runtimeType);
                print(error);
              }
            },
            child: const Text("Login"),
          ),
        ],
      )
    );
  }
}
