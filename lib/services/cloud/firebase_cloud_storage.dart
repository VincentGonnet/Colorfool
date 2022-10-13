import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colorfool/services/cloud/cloud_color.dart';
import 'package:colorfool/services/cloud/cloud_storage_constants.dart';
import 'package:colorfool/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final colors = FirebaseFirestore.instance.collection('colors');

  Stream<Iterable<CloudColor>> allColors({required String ownerUserId}) =>
      colors.snapshots().map((query) => query.docs
          .map((doc) => CloudColor.fromSnapshot(doc))
          .where((color) => color.ownerUserId == ownerUserId));

  void createNewColor({required String ownerUserId}) async {
    await colors.add({
      ownerUserIdFieldName: ownerUserId,
      colorCodeFieldName: '',
    });
  }

  Future<Iterable<CloudColor>> getColors({required String ownerUserId}) async {
    try {
      return await colors
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) {
              return CloudColor(
                documentId: doc.id,
                ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                colorCode: doc.data()[colorCodeFieldName] as String,
              );
            }),
          );
    } catch (e) {
      throw CouldNotGetAllColorsException();
    }
  }

  Future<void> updateColor(
      {required String documentId, required String colorCode}) async {
    try {
      await colors.doc(documentId).update({colorCodeFieldName: colorCode});
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
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
