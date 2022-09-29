import 'package:colorfool/services/crud/colors_service.dart';
import 'package:flutter/material.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef ColorCallback = void Function(DatabaseColor color);

class ColorsListView extends StatelessWidget {
  final List<DatabaseColor> colors;
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
        final color = colors[index];
        return ListTile(
          title: Text(
            color.colorCode,
            maxLines: 1,
          ),
          onTap: () {
            onTap(color);
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteColor(color);
              }
            },
          ),
        );
      },
    );
  }
}
