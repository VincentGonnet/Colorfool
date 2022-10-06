import 'package:colorfool/constants/routes.dart';
import 'package:colorfool/services/auth/auth_exceptions.dart';
import 'package:colorfool/services/auth/auth_service.dart';
import 'package:colorfool/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text("Register"),
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
                  labelText: "Email"),
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
                try {
                  await AuthService.firebase()
                      .createUser(email: email, password: password);
                  AuthService.firebase().currentUser;
                  AuthService.firebase().sendEmailVerification();
                  if (!mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                } on WeakPasswordAuthException {
                  await showErrorDialog(context, "Weak Password");
                } on EmailAlreadyInUseAuthException {
                  await showErrorDialog(context, "Email already taken");
                } on InvalidEmailAuthException {
                  await showErrorDialog(context, "Invalid email");
                } on GenericAuthException {
                  await showErrorDialog(context, "Failed to register");
                }
              },
              child: const Text("Register"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text("Already registered? Login here!"),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
