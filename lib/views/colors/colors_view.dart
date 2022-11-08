import 'package:colorfool/services/auth/auth_service.dart';
import 'package:colorfool/services/auth/bloc/auth_bloc.dart';
import 'package:colorfool/services/auth/bloc/auth_events.dart';
import 'package:colorfool/services/cloud/cloud_color.dart';
import 'package:colorfool/services/cloud/firebase_cloud_storage.dart';
import 'package:colorfool/views/colors/colors_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class ColorsView extends StatefulWidget {
  const ColorsView({Key? key}) : super(key: key);

  @override
  State<ColorsView> createState() => _ColorsViewState();
}

class _ColorsViewState extends State<ColorsView> {
  late final FirebaseCloudStorage _colorsService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _colorsService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Colors"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createUpdateColorRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                if (shouldLogout) {
                  if (!mounted) return;
                  context.read<AuthBloc>().add(const AuthEventLogOut());
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
      body: StreamBuilder(
        stream: _colorsService.allColors(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allColors = snapshot.data as Iterable<CloudColor>;
                return ColorsListView(
                  colors: allColors,
                  onDeleteColor: (color) async {
                    await _colorsService.deleteColor(
                        documentId: color.documentId);
                  },
                  onTap: (color) {
                    Navigator.of(context).pushNamed(
                      createUpdateColorRoute,
                      arguments: color,
                    );
                  },
                );
              }
              return const Text("Waiting for data to be added");
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
