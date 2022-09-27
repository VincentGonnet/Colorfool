import 'package:colorfool/services/auth/auth_service.dart';
import 'package:colorfool/services/crud/colors_service.dart';
import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../enums/menu_action.dart';

class ColorsView extends StatefulWidget {
  const ColorsView({Key? key}) : super(key: key);

  @override
  State<ColorsView> createState() => _ColorsViewState();
}

class _ColorsViewState extends State<ColorsView> {
  late final ColorsService _colorsService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _colorsService = ColorsService();
    _colorsService.open();
    super.initState();
  }

  @override
  void dispose() {
    _colorsService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Colors"),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                if (shouldLogout) {
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                } else {
                  return;
                }
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
      body: FutureBuilder(
        future: _colorsService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _colorsService.allColors,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text("Waiting for all colors...");
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
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
