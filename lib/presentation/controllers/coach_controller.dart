import 'package:flutter/material.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/entities/coach_work_session_entity.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/training_template_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/repositories/training_template_repository.dart';

class CoachController extends ChangeNotifier {
  final CoachRepository _coachRepository;
  final AttendanceRepository _attendanceRepository;
  final PlayerRepository _playerRepository;
  final TrainingTemplateRepository _templateRepository;

  CoachEntity? _coach;
  CoachEntity? get coach => _coach;

  CoachWorkSessionEntity? _activeSession;
  CoachWorkSessionEntity? get activeSession => _activeSession;

  bool _isCheckingInOut = false;
  bool get isCheckingInOut => _isCheckingInOut;

  // Scanned Player state
  PlayerEntity? _scannedPlayer;
  PlayerEntity? get scannedPlayer => _scannedPlayer;

  bool _isVerifyingPlayer = false;
  bool get isVerifyingPlayer => _isVerifyingPlayer;

  String? _scanError;
  String? get scanError => _scanError;

  // Attendance history
  List<AttendanceEntity> _coachAttendance = [];
  List<AttendanceEntity> get coachAttendance => _coachAttendance;

  // Templates
  List<TrainingTemplateEntity> _templates = [];
  List<TrainingTemplateEntity> get templates => _templates;

  CoachController({
    required CoachRepository coachRepository,
    required AttendanceRepository attendanceRepository,
    required PlayerRepository playerRepository,
    required TrainingTemplateRepository templateRepository,
  })  : _coachRepository = coachRepository,
        _attendanceRepository = attendanceRepository,
        _playerRepository = playerRepository,
        _templateRepository = templateRepository;

  Future<void> initializeCoach(String coachId) async {
    final coachRes = await _coachRepository.getCoachById(coachId);
    coachRes.fold((l) => null, (r) => _coach = r);

    await checkActiveSession(coachId);
    await loadRecentAttendance(coachId);
    await loadTemplates();
    notifyListeners();
  }

  Future<void> checkActiveSession(String coachId) async {
    final res = await _coachRepository.getActiveWorkSession(coachId);
    _activeSession = res.fold((l) => null, (r) => r);
    notifyListeners();
  }

  Future<bool> checkIn(String coachId, String coachName) async {
    _isCheckingInOut = true;
    notifyListeners();

    final res = await _coachRepository.checkInCoach(coachId, coachName);
    _isCheckingInOut = false;

    return res.fold(
      (l) {
        notifyListeners();
        return false;
      },
      (session) {
        _activeSession = session;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> checkOut(String coachId, [double? rate]) async {
    _isCheckingInOut = true;
    notifyListeners();

    final hourlyRate = rate ?? _coach?.hourlyRate ?? 50.0;
    final res = await _coachRepository.checkOutCoach(coachId, hourlyRate);
    _isCheckingInOut = false;

    return res.fold(
      (l) {
        notifyListeners();
        return false;
      },
      (session) {
        _activeSession = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> verifyPlayer(String playerId) async {
    _isVerifyingPlayer = true;
    _scanError = null;
    _scannedPlayer = null;
    notifyListeners();

    final res = await _playerRepository.getPlayerById(playerId);
    _isVerifyingPlayer = false;

    return res.fold(
      (l) {
        _scanError = 'Player not found with ID: $playerId';
        notifyListeners();
        return false;
      },
      (player) {
        _scannedPlayer = player;
        notifyListeners();
        return true;
      },
    );
  }

  void clearScannedPlayer() {
    _scannedPlayer = null;
    _scanError = null;
    notifyListeners();
  }

  Future<bool> markAttendance({
    required String coachId,
    required String coachName,
    required String type, // 'fitness' or 'recovery'
    int sessionPrice = 100,
    String? workoutId,
    String? workoutName,
    Map<String, dynamic>? workoutDetails,
  }) async {
    if (_scannedPlayer == null) return false;

    final res = await _attendanceRepository.recordAttendanceAtomic(
      coachId: coachId,
      coachName: coachName,
      playerId: _scannedPlayer!.id,
      type: type,
      sessionPrice: sessionPrice,
      workoutId: workoutId,
      workoutName: workoutName,
      workoutDetails: workoutDetails,
    );

    return res.fold(
      (l) {
        _scanError = l.message;
        notifyListeners();
        return false;
      },
      (attendance) {
        _scannedPlayer = null;
        loadRecentAttendance(coachId);
        return true;
      },
    );
  }

  Future<void> loadRecentAttendance(String coachId) async {
    final res = await _attendanceRepository.getAttendanceByCoachId(coachId);
    _coachAttendance = res.fold((l) => [], (r) => r);
    notifyListeners();
  }

  Future<void> loadTemplates() async {
    final res = await _templateRepository.getTemplates();
    _templates = res.fold((l) => [], (r) => r);
    notifyListeners();
  }
}
