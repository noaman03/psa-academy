import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/pages/login_screen.dart';
import 'package:psa_academy/pages/signup_screen.dart';
import 'package:psa_academy/pages/trainingTemplates.dart';
import 'package:psa_academy/pages/trainingTemplatesClone.dart';
import 'package:psa_academy/service/provider/adminProvider.dart';
import 'package:psa_academy/service/provider/authProvider.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'package:psa_academy/utils/export_pdf.dart';
import 'admin_widgets/admin_widgets.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final TextEditingController searchController = TextEditingController();
  bool isSearchActive = false;

  // Controllers for expense entry
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  bool expenseOptionsshow = true;

  // Date range filters
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _expenseOptions = [
    'Rent',
    'Utilities',
    'Salaries',
    'Equipment'
  ];

  // Tab controller for finance/attendance reports
  late TabController _reportTabController;

  // Player and coach counts
  int _playerCount = 0;
  int _coachCount = 0;

  @override
  void initState() {
    super.initState();
    _reportTabController = TabController(length: 2, vsync: this);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.loadAdminName();
    adminProvider.loadReports();

    _loadPlayerCount();
    _loadCoachCount();
    _loadExpenseCategories();

    _titleFocusNode.addListener(() {
      if (_titleFocusNode.hasFocus) {
        setState(() {
          expenseOptionsshow = false;
        });
      } else {
        setState(() {
          expenseOptionsshow = true;
        });
      }
    });
  }

  Future<void> _loadPlayerCount() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('players').get();
      setState(() {
        _playerCount = snapshot.docs.length;
      });
    } catch (e) {
      print('Error loading player count: $e');
    }
  }

  Future<void> _loadCoachCount() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('coaches').get();
      setState(() {
        _coachCount = snapshot.docs.length;
      });
    } catch (e) {
      print('Error loading coach count: $e');
    }
  }

  Future<void> _loadExpenseCategories() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('expenseCategories')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['categories'] != null) {
          setState(() {
            _expenseOptions.clear();
            _expenseOptions.addAll(
              List<String>.from(data['categories']),
            );
          });
        }
      }
    } catch (e) {
      print('Error loading expense categories: $e');
    }
  }

  @override
  void dispose() {
    _reportTabController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    searchController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final theme = Theme.of(context);

    // Apply date filters
    final filteredPayments = adminProvider.reportsPayments.where((payment) {
      final paymentDate = (payment['date'] as Timestamp).toDate();
      return (_startDate == null || paymentDate.isAfter(_startDate!)) &&
          (_endDate == null || paymentDate.isBefore(_endDate!));
    }).toList();

    final filteredExpenses = adminProvider.reportsExpences.where((expense) {
      final expenseDate = (expense['date'] as Timestamp).toDate();
      return (_startDate == null || expenseDate.isAfter(_startDate!)) &&
          (_endDate == null || expenseDate.isBefore(_endDate!));
    }).toList();

    final filteredAttendance =
        adminProvider.reportsAttendace.where((attendance) {
      final attendanceDate = (attendance['date'] as Timestamp).toDate();
      return (_startDate == null || attendanceDate.isAfter(_startDate!)) &&
          (_endDate == null || attendanceDate.isBefore(_endDate!));
    }).toList();

    final double totalAmount = filteredPayments
            .where((payment) => payment['status'] == 'paid')
            .fold(0, (sum, payment) => sum + (payment['amount'] as int)) -
        filteredExpenses.fold(0, (sum, expense) => sum + expense['amount']);

    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        backgroundColor: lightPink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: isSearchActive
            ? _buildSearchField()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Dashboard',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    adminProvider.adminName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
        actions: isSearchActive
            ? [
                IconButton(
                  icon: const Icon(Icons.close, color: darkBlue),
                  onPressed: () {
                    setState(() {
                      isSearchActive = false;
                      searchController.clear();
                    });
                  },
                )
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search, color: darkBlue),
                  onPressed: () {
                    setState(() {
                      isSearchActive = true;
                    });
                  },
                ),
              ],
      ),
      body: isSearchActive && searchController.text.isNotEmpty
          ? _buildSearchResults()
          : _buildTabContent(
              index: _currentIndex,
              adminProvider: adminProvider,
              totalAmount: totalAmount,
              filteredPayments: filteredPayments,
              filteredExpenses: filteredExpenses,
              filteredAttendance: filteredAttendance,
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: mediumBlue,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Finance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0: // Dashboard
        return null;
      case 1: // Finance
        return FloatingActionButton(
          onPressed: () => _showAddExpenseDialog(),
          backgroundColor: mediumBlue,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 2: // Attendance
        return null;
      case 3: // Settings
        return null;
      default:
        return null;
    }
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddExpenseDialog(
          expenseOptions: _expenseOptions,
          titleController: _titleController,
          amountController: _amountController,
          titleFocusNode: _titleFocusNode,
          expenseOptionsShow: expenseOptionsshow,
          onExpenseOptionsShowChanged: (value) {
            setState(() {
              expenseOptionsshow = value;
            });
          },
        );
      },
    ).then((_) {
      // Reload data after dialog closes
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadReports();
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search users...',
        border: InputBorder.none,
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildSearchResults() {
    return SearchResultsList(searchQuery: searchController.text);
  }

  Widget _buildTabContent({
    required int index,
    required AdminProvider adminProvider,
    required double totalAmount,
    required List<Map<String, dynamic>> filteredPayments,
    required List<Map<String, dynamic>> filteredExpenses,
    required List<Map<String, dynamic>> filteredAttendance,
  }) {
    switch (index) {
      case 0:
        return _buildDashboardTab(
            adminProvider, totalAmount, filteredAttendance.length);
      case 1:
        return _buildFinanceTab(
            adminProvider, totalAmount, filteredPayments, filteredExpenses);
      case 2:
        return _buildAttendanceTab(filteredAttendance);
      case 3:
        return _buildSettingsTab(adminProvider);
      default:
        return const Center(child: Text('Tab content not available'));
    }
  }

  Widget _buildDashboardTab(
      AdminProvider adminProvider, double totalAmount, int attendanceCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildStatsCards(totalAmount, attendanceCount),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionCards(),
        ],
      ),
    );
  }

  Widget _buildStatsCards(double totalAmount, int attendanceCount) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Current Balance',
                value: '\$${totalAmount.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: mediumBlue,
                gradientColors: [darkBlue, mediumBlue],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Total Attendance',
                value: attendanceCount.toString(),
                icon: Icons.people,
                color: const Color(0xFFF79009),
                gradientColors: const [Color(0xFFF79009), Color(0xFFFDB022)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Active Players',
                value: _playerCount.toString(),
                icon: Icons.person,
                color: const Color(0xFF12B76A),
                gradientColors: const [Color(0xFF039855), Color(0xFF12B76A)],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Active Coaches',
                value: _coachCount.toString(),
                icon: Icons.sports,
                color: const Color(0xFF2E90FA),
                gradientColors: const [Color(0xFF175CD3), Color(0xFF2E90FA)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        ActionCard(
          title: 'Add User',
          icon: Icons.person_add,
          color: mediumBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupScreen()),
          ),
        ),
        ActionCard(
          title: 'Training Templates',
          icon: Icons.fitness_center,
          color: Colors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TrainingTemplatesPage()),
          ),
        ),
        ActionCard(
          title: 'Add Expense',
          icon: Icons.money_off,
          color: Colors.red,
          onTap: () => _showAddExpenseDialog(),
        ),
        ActionCard(
          title: 'Export Reports',
          icon: Icons.picture_as_pdf,
          color: const Color(0xFFF79009),
          onTap: () {
            setState(() {
              _currentIndex = 1; // Switch to Finance tab
            });
          },
        ),
      ],
    );
  }

  Widget _buildFinanceTab(
    AdminProvider adminProvider,
    double totalAmount,
    List<Map<String, dynamic>> filteredPayments,
    List<Map<String, dynamic>> filteredExpenses,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BalanceCard(totalAmount: totalAmount),
              const SizedBox(height: 16),
              DateRangePicker(
                startDate: _startDate,
                endDate: _endDate,
                onPickStartDate: _pickStartDate,
                onPickEndDate: _pickEndDate,
              ),
              const SizedBox(height: 16),
              ExportButtonsRow(
                onExportPdf: () => _exportFinanceReport(
                  adminProvider,
                  totalAmount,
                  filteredPayments,
                  filteredExpenses,
                ),
                onAddExpense: _showAddExpenseDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: buildFinanceReportList(
            filteredPayments,
            filteredExpenses,
            "Finance",
          ),
        ),
      ],
    );
  }

  void _exportFinanceReport(
    AdminProvider provider,
    double totalAmount,
    List<Map<String, dynamic>> filteredPayments,
    List<Map<String, dynamic>> filteredExpenses,
  ) async {
    final data = [
      ['Title', 'Amount', 'Date', 'Status'],
      ...filteredExpenses.map((expense) => [
            expense['title'],
            expense['amount'].toString(),
            DateFormat('yyyy-MM-dd')
                .format((expense['date'] as Timestamp).toDate()),
            'Expense'
          ]),
      ...await Future.wait(filteredPayments.map((payment) async {
        final playerName = await _fetchPlayerName(payment['playerId']);
        return [
          playerName,
          payment['amount'].toString(),
          DateFormat('yyyy-MM-dd')
              .format((payment['date'] as Timestamp).toDate()),
          payment['status']
        ];
      })),
    ];

    final startDateStr = _startDate != null
        ? DateFormat('yyyy-MM-dd').format(_startDate!)
        : 'Start';
    final endDateStr =
        _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'End';

    final fileName = 'Finance Report $startDateStr to $endDateStr';

    exportPDF(data, fileName, totalAmount: totalAmount);
  }

  Future<String> _fetchPlayerName(String playerId) async {
    final playerDoc = await FirebaseFirestore.instance
        .collection('players')
        .doc(playerId)
        .get();
    return playerDoc.exists ? playerDoc['name'] : 'Unknown Player';
  }

  Future<String> _fetchCoachName(String coachId) async {
    final coachDoc = await FirebaseFirestore.instance
        .collection('coaches')
        .doc(coachId)
        .get();
    return coachDoc.exists ? coachDoc['name'] : 'Unknown Coach';
  }

  Widget buildFinanceReportList(
    List<Map<String, dynamic>> reportpayment,
    List<Map<String, dynamic>> reportexpenses,
    String title,
  ) {
    // Combine and sort all entries
    final allEntries = [
      ...reportpayment.map((p) => FinanceEntry.fromPayment(p)),
      ...reportexpenses.map((e) => FinanceEntry.fromExpense(e)),
    ]..sort((a, b) => b.date.compareTo(a.date));

    // Group by formatted date
    final groupedEntries =
        groupBy(allEntries, (entry) => _formatDate(entry.date));

    // Get sorted dates (newest first)
    final dates = groupedEntries.keys.toList()
      ..sort((a, b) => DateFormat('MMMM d')
          .parse(b)
          .compareTo(DateFormat('MMMM d').parse(a)));

    if (dates.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.account_balance_wallet_outlined,
        message: 'No finance records in selected period',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final entries = groupedEntries[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateHeader(date: date),
            ...entries.map((entry) => FinanceItem(
                  entry: entry,
                  fetchPlayerName: _fetchPlayerName,
                )),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) => DateFormat('MMMM d').format(date);

  Widget _buildAttendanceTab(List<Map<String, dynamic>> filteredAttendance) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DateRangePicker(
                startDate: _startDate,
                endDate: _endDate,
                onPickStartDate: _pickStartDate,
                onPickEndDate: _pickEndDate,
              ),
              const SizedBox(height: 16),
              ExportButton(
                label: 'Export Attendance',
                onPressed: () => _exportAttendanceReport(filteredAttendance),
              ),
            ],
          ),
        ),
        Expanded(
          child: buildAttendaceReportList(filteredAttendance, "Attendance"),
        ),
      ],
    );
  }

  void _exportAttendanceReport(
      List<Map<String, dynamic>> filteredAttendance) async {
    final data = [
      ['Player', 'Coach', 'Date', 'Time', 'Workout'],
      ...await Future.wait(filteredAttendance.map((attendance) async {
        final playerName = await _fetchPlayerName(attendance['playerId']);
        final coachName = await _fetchCoachName(attendance['coachId']);
        final dateTime = (attendance['date'] as Timestamp).toDate();
        return [
          playerName,
          coachName,
          DateFormat('yyyy-MM-dd').format(dateTime),
          DateFormat('h:mm a').format(dateTime),
          attendance['workout'] ?? 'No workout'
        ];
      })),
    ];

    exportPDF(data, 'Attendance Report');
  }

  Widget buildAttendaceReportList(
      List<Map<String, dynamic>> reportAttendance, String title) {
    if (reportAttendance.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.people_outline,
        message: 'No attendance records in selected period',
      );
    }

    final grouped = groupBy(reportAttendance,
        (entry) => _formatDate((entry['date'] as Timestamp).toDate()));

    final dates = grouped.keys.toList()
      ..sort((a, b) => DateFormat('MMMM d')
          .parse(b)
          .compareTo(DateFormat('MMMM d').parse(a)));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final entries = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateHeader(date: date),
            ...entries.map((entry) => AttendanceItem(
                  entry: entry,
                  fetchPlayerName: _fetchPlayerName,
                  fetchCoachName: _fetchCoachName,
                  onUpdateWorkout: _updateWorkout,
                )),
          ],
        );
      },
    );
  }

  void _updateWorkout(BuildContext context, Map<String, dynamic> entry) {
    // Navigate to TrainingTemplatesClonePage with attendance data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingTemplatesClonePage(
          attendanceId: entry['attendanceID'],
          playerId: entry['playerId'],
          date: entry['date'],
          currentWorkout: entry['workout'] ?? 'No workout',
        ),
      ),
    );
  }

  Widget _buildSettingsTab(AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          SettingsCard(
            icon: Icons.fitness_center,
            title: 'Training Templates',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TrainingTemplatesPage())),
          ),
          SettingsCard(
            icon: Icons.people,
            title: 'User Management',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignupScreen())),
          ),
          SettingsCard(
            icon: Icons.category,
            title: 'Expense Categories',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExpenseCategoriesDialog(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Provider.of<Authprovider>(context, listen: false)
                    .logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpenseCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => ExpenseCategoriesDialog(
        expenseOptions: _expenseOptions,
        onCategoriesChanged: (updatedCategories) {
          setState(() {
            _expenseOptions.clear();
            _expenseOptions.addAll(updatedCategories);
          });
        },
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }
}
