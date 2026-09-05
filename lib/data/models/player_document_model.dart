import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/date_parser.dart';
import '../../domain/entities/player_document_entity.dart';

class PlayerDocumentModel extends PlayerDocumentEntity {
  const PlayerDocumentModel({
    required super.id,
    required super.playerId,
    required super.fileName,
    required super.downloadUrl,
    required super.fileSize,
    required super.uploadDate,
  });

  factory PlayerDocumentModel.fromMap(String id, String playerId, Map<String, dynamic> data) {
    return PlayerDocumentModel(
      id: id,
      playerId: playerId,
      fileName: data['filename'] ?? data['fileName'] ?? 'Document',
      downloadUrl: data['url'] ?? data['downloadUrl'] ?? '',
      fileSize: (data['fileSize'] as num?)?.toInt() ?? 0,
      uploadDate: parseRequiredDateTime(data['uploadDate']),
    );
  }

  factory PlayerDocumentModel.fromFirestore(DocumentSnapshot doc, String playerId) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PlayerDocumentModel.fromMap(doc.id, playerId, data);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'playerId': playerId,
      'fileName': fileName,
      'downloadUrl': downloadUrl,
      'fileSize': fileSize,
      'uploadDate': Timestamp.fromDate(uploadDate),
    };
  }
}
