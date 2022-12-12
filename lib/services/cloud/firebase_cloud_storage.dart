import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colorfool/services/cloud/cloud_color.dart';
import 'package:colorfool/services/cloud/cloud_storage_constants.dart';
import 'package:colorfool/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final colors = FirebaseFirestore.instance.collection('colors');
  late int highestOrder;

  Stream<Iterable<CloudColor>> allColors(
          {required String ownerUserId}) =>
      colors
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .snapshots()
          .map(
              (query) => query.docs.map((doc) => CloudColor.fromSnapshot(doc)));

  Future<CloudColor> createNewColor({required String ownerUserId}) async {
    final document = await colors.add({
      ownerUserIdFieldName: ownerUserId,
      colorCodeFieldName: '',
      orderFieldName: highestOrder + 1,
    });
    final fetchedColor = await document.get();
    return CloudColor(
      documentId: fetchedColor.id,
      ownerUserId: ownerUserId,
      colorCode: "",
      order: highestOrder + 1,
    );
  }

  Future<void> updateColor(
      {required String documentId, required String colorCode}) async {
    try {
      await colors.doc(documentId).update({colorCodeFieldName: colorCode});
    } catch (_) {
      throw CouldNotUpdateColorException();
    }
  }

  Future<void> updateOrder({required List<CloudColor> colorList}) async {
    final batch = FirebaseFirestore.instance.batch();
    try {
      for (int pos = 0; pos < colorList.length; pos++) {
        batch.update(
            colors.doc(colorList[pos].documentId), {orderFieldName: pos});
      }
      batch.commit();
    } catch (_) {
      throw CouldNotUpdateColorException();
    }
  }

  Future<void> deleteColor({required String documentId}) async {
    try {
      await colors.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteColorException();
    }
  }

  // make FirebaseCloudStorage a singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
  FirebaseCloudStorage._sharedInstance();
}
