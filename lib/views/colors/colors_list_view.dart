import 'package:colorfool/services/cloud/cloud_color.dart';
import 'package:colorfool/utilities/conversions/color_code.dart';
import 'package:flutter/material.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef ColorCallback = void Function(CloudColor color);

class ColorsListView extends StatelessWidget {
  final Iterable<CloudColor> colors;
  final ColorCallback onDeleteColor;
  final ColorCallback onTap;

  const ColorsListView({
    Key? key,
    required this.colors,
    required this.onDeleteColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors.elementAt(index);
        return Container(
            padding: const EdgeInsets.all(5),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onTap: () {
                onTap(color);
              },
              tileColor: getColorFromFormattedCode(color.colorCode),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: () async {
                  final shouldDelete = await showDeleteDialog(context);
                  if (shouldDelete) {
                    onDeleteColor(color);
                  }
                },
              ),
            ));
      },
    );
  }
}
