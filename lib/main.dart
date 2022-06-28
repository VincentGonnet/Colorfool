import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:io' show Platform;

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
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      print("Loaded on Windows");
      firebaseApp = Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAGCQOM5y0sdl3LNKmCqejYQBHniV4JH3U',
            appId: '1:331560952012:android:a98d2f37f46a0b24cf6269',
            messagingSenderId: '331560952012',
            projectId: 'colorfool',
          ),
      );
    } else {
      print("Loaded elsewhere");
      firebaseApp = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
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
                      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: email,
                          password: password
                      );
                      print(userCredential);
                    },
                    child: const Text("Register"),
                  ),
                ],
              );
            default:
              return const Text("Loading");
          }
        },
      ),
    );
  }
}
