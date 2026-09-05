import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/state/view_state.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/player_document_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/player_repository.dart';

class PlayerController extends ChangeNotifier {
  final PlayerRepository _playerRepository;
  final AttendanceRepository _attendanceRepository;

  PlayerEntity? _player;
  PlayerEntity? get player => _player;

  StreamSubscription<PlayerEntity?>? _playerSubscription;

  ViewState<List<AttendanceEntity>> _attendanceState =
      const ViewState.initial();
  ViewState<List<AttendanceEntity>> get attendanceState => _attendanceState;

  List<PlayerDocumentEntity> _documents = [];
  List<PlayerDocumentEntity> get documents => _documents;

  bool _isUploadingDocument = false;
  bool get isUploadingDocument => _isUploadingDocument;

  PlayerController({
    required PlayerRepository playerRepository,
    required AttendanceRepository attendanceRepository,
  })  : _playerRepository = playerRepository,
        _attendanceRepository = attendanceRepository;

  void initializePlayer(String playerId) {
    _playerSubscription?.cancel();
    _playerSubscription = _playerRepository.watchPlayer(playerId).listen((p) {
      _player = p;
      notifyListeners();
    });

    loadAttendance(playerId);
    loadDocuments(playerId);
  }

  Future<void> loadAttendance(String playerId) async {
    _attendanceState = const ViewState.loading();
    notifyListeners();

    final res = await _attendanceRepository.getAttendanceByPlayerId(playerId);
    res.fold(
      (l) => _attendanceState = ViewState.failure(l.message),
      (r) => _attendanceState =
          r.isEmpty ? const ViewState.empty() : ViewState.success(r),
    );
    notifyListeners();
  }

  Future<void> loadDocuments(String playerId) async {
    final res = await _playerRepository.getPlayerDocuments(playerId);
    _documents = res.fold((l) => [], (r) => r);
    notifyListeners();
  }

  Future<bool> uploadDocument(
    String playerId, {
    required String fileName,
    required Uint8List bytes,
  }) async {
    _isUploadingDocument = true;
    notifyListeners();

    final res = await _playerRepository.uploadDocument(
      playerId: playerId,
      fileName: fileName,
      bytes: bytes,
    );

    _isUploadingDocument = false;
    return res.fold(
      (l) {
        notifyListeners();
        return false;
      },
      (doc) {
        _documents.insert(0, doc);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteDocument(
    String playerId,
    String documentId,
    String fileUrl,
  ) async {
    final res = await _playerRepository.deleteDocument(
      playerId,
      documentId,
      fileUrl,
    );

    return res.fold(
      (l) => false,
      (_) {
        _documents.removeWhere((d) => d.id == documentId);
        notifyListeners();
        return true;
      },
    );
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    super.dispose();
  }
}
