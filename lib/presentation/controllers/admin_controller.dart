import 'package:flutter/material.dart';
import '../../core/state/view_state.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/training_template_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/repositories/training_template_repository.dart';

class AdminDashboardData {
  final int playerCount;
  final int coachCount;
  final int todayAttendanceCount;
  final FinancialSummary financialSummary;
  final List<AttendanceEntity> recentAttendance;

  const AdminDashboardData({
    required this.playerCount,
    required this.coachCount,
    required this.todayAttendanceCount,
    required this.financialSummary,
    required this.recentAttendance,
  });
}

class AdminController extends ChangeNotifier {
  final PlayerRepository _playerRepository;
  final CoachRepository _coachRepository;
  final AttendanceRepository _attendanceRepository;
  final FinanceRepository _financeRepository;
  final TrainingTemplateRepository _templateRepository;

  ViewState<AdminDashboardData> _dashboardState = const ViewState.initial();
  ViewState<AdminDashboardData> get dashboardState => _dashboardState;

  // Finance State
  ViewState<List<PaymentEntity>> _paymentsState = const ViewState.initial();
  ViewState<List<PaymentEntity>> get paymentsState => _paymentsState;

  ViewState<List<ExpenseEntity>> _expensesState = const ViewState.initial();
  ViewState<List<ExpenseEntity>> get expensesState => _expensesState;

  FinancialSummary? _financialSummary;
  FinancialSummary? get financialSummary => _financialSummary;

  // Users State
  List<PlayerEntity> _players = [];
  List<PlayerEntity> get players => _players;

  List<CoachEntity> _coaches = [];
  List<CoachEntity> get coaches => _coaches;

  bool _isLoadingUsers = false;
  bool get isLoadingUsers => _isLoadingUsers;

  // Training Templates State
  List<TrainingTemplateEntity> _templates = [];
  List<TrainingTemplateEntity> get templates => _templates;

  AdminController({
    required PlayerRepository playerRepository,
    required CoachRepository coachRepository,
    required AttendanceRepository attendanceRepository,
    required FinanceRepository financeRepository,
    required TrainingTemplateRepository templateRepository,
  })  : _playerRepository = playerRepository,
        _coachRepository = coachRepository,
        _attendanceRepository = attendanceRepository,
        _financeRepository = financeRepository,
        _templateRepository = templateRepository;

  Future<void> loadDashboard() async {
    _dashboardState = const ViewState.loading();
    notifyListeners();

    try {
      final playersRes = await _playerRepository.getAllPlayers();
      final coachesRes = await _coachRepository.getAllCoaches();

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final attendanceRes = await _attendanceRepository.getAttendanceByDateRange(
        startOfDay,
        endOfDay,
      );

      final financeRes = await _financeRepository.getFinancialSummary();

      final int pCount = playersRes.fold((l) => 0, (r) => r.length);
      final int cCount = coachesRes.fold((l) => 0, (r) => r.length);
      final int todayCount = attendanceRes.fold((l) => 0, (r) => r.length);
      final recentAtt = attendanceRes.fold((l) => <AttendanceEntity>[], (r) => r);

      final summary = financeRes.fold(
        (l) => const FinancialSummary(
          totalRevenue: 0,
          totalExpenses: 0,
          netBalance: 0,
          totalPaidTransactions: 0,
          pendingCount: 0,
        ),
        (r) => r,
      );

      _dashboardState = ViewState.success(
        AdminDashboardData(
          playerCount: pCount,
          coachCount: cCount,
          todayAttendanceCount: todayCount,
          financialSummary: summary,
          recentAttendance: recentAtt,
        ),
      );
      notifyListeners();
    } catch (e) {
      _dashboardState = ViewState.failure('Failed to load dashboard: $e');
      notifyListeners();
    }
  }

  Future<void> loadFinanceData({DateTime? start, DateTime? end}) async {
    _paymentsState = const ViewState.loading();
    _expensesState = const ViewState.loading();
    notifyListeners();

    final paymentsRes = await _financeRepository.getPayments(
      startDate: start,
      endDate: end,
    );
    paymentsRes.fold(
      (l) => _paymentsState = ViewState.failure(l.message),
      (r) => _paymentsState = r.isEmpty ? const ViewState.empty() : ViewState.success(r),
    );

    final expensesRes = await _financeRepository.getExpenses(
      startDate: start,
      endDate: end,
    );
    expensesRes.fold(
      (l) => _expensesState = ViewState.failure(l.message),
      (r) => _expensesState = r.isEmpty ? const ViewState.empty() : ViewState.success(r),
    );

    final summaryRes = await _financeRepository.getFinancialSummary(
      startDate: start,
      endDate: end,
    );
    _financialSummary = summaryRes.fold((l) => null, (r) => r);

    notifyListeners();
  }

  Future<bool> addExpense({
    required String title,
    required String category,
    required double amount,
    String? notes,
  }) async {
    final result = await _financeRepository.addExpense(
      title: title,
      category: category,
      amount: amount,
      notes: notes,
    );

    return result.fold(
      (l) => false,
      (expense) {
        loadFinanceData();
        return true;
      },
    );
  }

  Future<bool> addPayment(PaymentEntity payment) async {
    final result = await _financeRepository.addPayment(payment);
    return result.fold(
      (l) => false,
      (p) {
        loadFinanceData();
        return true;
      },
    );
  }

  Future<bool> createPlayer(PlayerEntity player) async {
    final result = await _playerRepository.createPlayer(player);
    return result.fold(
      (l) => false,
      (p) {
        loadUsers();
        return true;
      },
    );
  }

  Future<bool> deletePlayer(String playerId) async {
    final result = await _playerRepository.deletePlayer(playerId);
    return result.fold(
      (l) => false,
      (_) {
        loadUsers();
        return true;
      },
    );
  }

  Future<bool> createCoach(CoachEntity coach) async {
    final result = await _coachRepository.createCoach(coach);
    return result.fold(
      (l) => false,
      (c) {
        loadUsers();
        return true;
      },
    );
  }

  Future<bool> deleteCoach(String coachId) async {
    final result = await _coachRepository.deleteCoach(coachId);
    return result.fold(
      (l) => false,
      (_) {
        loadUsers();
        return true;
      },
    );
  }

  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    notifyListeners();

    final pRes = await _playerRepository.getAllPlayers();
    final cRes = await _coachRepository.getAllCoaches();

    _players = pRes.fold((l) => [], (r) => r);
    _coaches = cRes.fold((l) => [], (r) => r);

    _isLoadingUsers = false;
    notifyListeners();
  }

  Future<bool> togglePlayerAllowed(PlayerEntity player) async {
    final updated = (player as dynamic).copyWith(
      isAllowedPlayer: !player.isAllowedPlayer,
    );
    final res = await _playerRepository.updatePlayer(updated);
    return res.fold((l) => false, (r) {
      loadUsers();
      return true;
    });
  }

  Future<bool> toggleCoachAllowed(CoachEntity coach) async {
    final updated = (coach as dynamic).copyWith(
      isAllowedCoach: !coach.isAllowedCoach,
    );
    final res = await _coachRepository.updateCoach(updated);
    return res.fold((l) => false, (r) {
      loadUsers();
      return true;
    });
  }

  Future<bool> assignPlayerSessions(
    String playerId, {
    required int sessions,
    required double amount,
  }) async {
    final res = await _playerRepository.updateSessionBalance(
      playerId,
      additionalSessions: sessions,
      additionalAmount: amount,
    );
    return res.fold((l) => false, (r) {
      loadUsers();
      return true;
    });
  }

  Future<void> loadTemplates() async {
    final res = await _templateRepository.getTemplates();
    _templates = res.fold((l) => [], (r) => r);
    notifyListeners();
  }

  Future<bool> createTemplate(TrainingTemplateEntity template) async {
    final res = await _templateRepository.createTemplate(template);
    return res.fold((l) => false, (r) {
      loadTemplates();
      return true;
    });
  }

  Future<bool> deleteTemplate(String templateId) async {
    final res = await _templateRepository.deleteTemplate(templateId);
    return res.fold((l) => false, (r) {
      loadTemplates();
      return true;
    });
  }
}
