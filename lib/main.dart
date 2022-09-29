import 'package:colorfool/constants/routes.dart';
import 'package:colorfool/services/auth/auth_service.dart';
import 'package:colorfool/views/colors/colors_view.dart';
import 'package:colorfool/views/colors/create_update_color_view.dart';
import 'package:colorfool/views/login_view.dart';
import 'package:colorfool/views/register_view.dart';
import 'package:colorfool/views/verify_email_view.dart';

import 'package:flutter/material.dart';

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
        createUpdateColorRoute: (context) => const CreateUpdateColorView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                } else {
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
