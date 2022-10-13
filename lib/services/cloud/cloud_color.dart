import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colorfool/services/cloud/cloud_storage_constants.dart';

class CloudColor {
  final String documentId;
  final String ownerUserId;
  final String colorCode;
  const CloudColor({
    required this.documentId,
    required this.ownerUserId,
    required this.colorCode,
  });

  CloudColor.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        colorCode = snapshot.data()[colorCodeFieldName] as String;
}
