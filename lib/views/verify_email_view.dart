import 'package:colorfool/services/auth/bloc/auth_bloc.dart';
import 'package:colorfool/services/auth/bloc/auth_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify your email"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            const Spacer(flex: 8),
            const Icon(
              Icons.mark_email_unread_outlined,
              size: 60,
              color: Colors.grey,
            ),
            const Spacer(),
            const Text(
              "We've sent you an email verification.",
              style: TextStyle(fontSize: 20),
            ),
            const Spacer(flex: 2),
            const Text(
              "Email not received / lost ?",
              style: TextStyle(fontSize: 14),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    context
                        .read<AuthBloc>()
                        .add(const AuthEventSendEmailVerification());
                  },
                  child: const Text("Send again"),
                ),
                TextButton(
                    onPressed: () async {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: const Text("Log Out")),
              ],
            ),
            const Spacer(flex: 10),
          ],
        ),
      ),
    );
  }
}
