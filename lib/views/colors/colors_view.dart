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
import 'package:google_fonts/google_fonts.dart';

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
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allColors = snapshot.data as Iterable<CloudColor>;

                // determine the highest color index
                final sortedColors = allColors.toList();
                sortedColors.sort((a, b) => b.order.compareTo(a.order));
                FirebaseCloudStorage().highestOrder = sortedColors[0].order;

                if (allColors.isEmpty) {
                  return Column(
                    children: [
                      const Spacer(flex: 4),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsetsDirectional.only(bottom: 10),
                        child: Text("Your color list is empty.",
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                            )),
                      ),
                      Text("Press + to create your first color",
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          )),
                      const Spacer(flex: 6)
                    ],
                  );
                } else {
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
              }

              return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            default:
              return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
