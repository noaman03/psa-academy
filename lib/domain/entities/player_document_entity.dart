import 'package:equatable/equatable.dart';

class PlayerDocumentEntity extends Equatable {
  final String id;
  final String playerId;
  final String fileName;
  final String downloadUrl;
  final int fileSize;
  final DateTime uploadDate;

  const PlayerDocumentEntity({
    required this.id,
    required this.playerId,
    required this.fileName,
    required this.downloadUrl,
    required this.fileSize,
    required this.uploadDate,
  });

  String get title => fileName;
  String get fileUrl => downloadUrl;
  DateTime get uploadedAt => uploadDate;
  String get fileType =>
      fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'file';

  @override
  List<Object?> get props =>
      [id, playerId, fileName, downloadUrl, fileSize, uploadDate];
}
