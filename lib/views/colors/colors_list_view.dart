import 'package:colorfool/services/crud/colors_service.dart';
import 'package:flutter/material.dart';

import '../../utilities/dialogs/delete_dialog.dart';

typedef DeleteColorCallback = void Function(DatabaseColor color);

class ColorsListView extends StatelessWidget {
  final List<DatabaseColor> colors;
  final DeleteColorCallback onDeleteColor;

  const ColorsListView({
    Key? key,
    required this.colors,
    required this.onDeleteColor,
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
