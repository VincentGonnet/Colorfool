import 'package:colorfool/constants/routes.dart';
import 'package:colorfool/services/auth/auth_exceptions.dart';
import 'package:colorfool/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:google_fonts/google_fonts.dart';

import '../utilities/dialogs/error_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              Container(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  "Colorfool",
                  style: GoogleFonts.montserrat(
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email here.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelText: "Email",
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Enter your password here.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    labelText: "Password",
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  if (email == "" || password == "") {
                    return await showErrorDialog(
                        context, "Please specify an email and a password");
                  }
                  try {
                    await AuthService.firebase()
                        .logIn(email: email, password: password);
                    final user = AuthService.firebase().currentUser;
                    if (user?.isEmailVerified ?? false) {
                      if (!mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        colorsRoute,
                        (route) => false,
                      );
                    } else {
                      if (!mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmailRoute,
                        (route) => false,
                      );
                    }
                  } on UserNotFoundAuthException {
                    await showErrorDialog(context, 'User not found');
                  } on WrongPasswordAuthException {
                    await showErrorDialog(context, 'Wrong password');
                  } on InvalidEmailAuthException {
                    await showErrorDialog(context, 'Invalid email');
                  } on GenericAuthException {
                    await showErrorDialog(context, 'Authentication error');
                  } catch (error) {
                    devtools.log("--- ERROR ---");
                    devtools.log(error.runtimeType.toString());
                    devtools.log(error.toString());
                  }
                },
                child: const Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
                child: const Text("Not registered yet? Register here!"),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ));
  }
}
