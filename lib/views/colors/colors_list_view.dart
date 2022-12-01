import 'package:colorfool/services/cloud/cloud_color.dart';
import 'package:colorfool/services/cloud/firebase_cloud_storage.dart';
import 'package:colorfool/utilities/conversions/color_code.dart';
import 'package:flutter/material.dart';

import '../../services/cloud/cloud_storage_constants.dart';
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

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 0,
          color: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorList = colors.toList();
    return Theme(
      data: ThemeData(canvasColor: Colors.transparent),
      child: ReorderableListView.builder(
        itemCount: colorList.length,
        proxyDecorator: proxyDecorator,
        itemBuilder: (context, index) {
          final color = colorList.elementAt(index);
          return Container(
            key: ValueKey(index),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: getColorFromFormattedCode(color.colorCode),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              onTap: () {
                onTap(color);
              },
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
            ),
          );
        },
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) newIndex -= 1;
          colorList.insert(newIndex, colorList.removeAt(oldIndex));
          final batch = FirebaseCloudStorage().batch;
          for (int pos = 0; pos < colorList.length; pos++) {
            batch.update(FirebaseCloudStorage().colors.doc(colorList[pos].documentId), {orderFieldName: pos});
          }
          batch.commit();
        },
      ),
    );
  }
}
