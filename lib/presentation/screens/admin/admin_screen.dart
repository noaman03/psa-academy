import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../routes/app_routes.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/admin_finance_tab.dart';
import 'tabs/admin_attendance_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_templates_tab.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboard();
    });
  }

  static const List<NavDestinationItem> _destinations = [
    NavDestinationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    NavDestinationItem(
      label: 'Finance',
      icon: Icons.attach_money_outlined,
      selectedIcon: Icons.attach_money,
    ),
    NavDestinationItem(
      label: 'Attendance',
      icon: Icons.fact_check_outlined,
      selectedIcon: Icons.fact_check,
    ),
    NavDestinationItem(
      label: 'Users',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    NavDestinationItem(
      label: 'Templates',
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center,
    ),
  ];

  static const List<String> _titles = [
    'Operations Dashboard',
    'Finance & Treasury',
    'Attendance Logs',
    'User Management',
    'Workout Templates',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final userName = auth.currentUser?.name ?? 'Admin';

    final bodies = [
      const AdminDashboardTab(),
      const AdminFinanceTab(),
      const AdminAttendanceTab(),
      const AdminUsersTab(),
      const AdminTemplatesTab(),
    ];

    return AppScaffold(
      title: _titles[_selectedIndex],
      roleBadgeText: 'Admin',
      userName: userName,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      destinations: _destinations,
      body: bodies[_selectedIndex],
      onLogout: () async {
        await context.read<AuthController>().signOut();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      },
    );
  }
}
