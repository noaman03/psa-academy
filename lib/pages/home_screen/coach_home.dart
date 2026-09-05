import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/pages/login_screen.dart';
import 'package:psa_academy/service/provider/authProvider.dart';
import 'package:psa_academy/service/provider/coachProvider.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'package:psa_academy/widgets/qr_scanner.dart';
import 'coach_widgets/coach_widgets.dart';

class CoachHome extends StatefulWidget {
  const CoachHome({super.key});

  @override
  State<CoachHome> createState() => _CoachHomeState();
}

class _CoachHomeState extends State<CoachHome> {
  int _selectedIndex = 0;
  // ignore: unused_field
  late Future<void> _loadCoachNameFuture;
  String? scannedPlayerId;
  String? scannedData;
  final TextEditingController _amountController = TextEditingController();
  bool isAllowed = false;

  final Map<String, double> recoveryTypes = {
    'Type 1': 50.0,
    'Type 2': 100.0,
    'Type 3': 150.0,
  };
  String? selectedRecoveryType;

  @override
  void initState() {
    super.initState();
    final String coachID = FirebaseAuth.instance.currentUser!.uid;
    final coachProvider = Provider.of<CoachProvider>(context, listen: false);
    _loadCoachNameFuture = coachProvider.loadcoachName(coachID);
    _fetchIsAllowedStatus(coachID);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchIsAllowedStatus(String coachID) async {
    try {
      DocumentSnapshot coachSnapshot = await FirebaseFirestore.instance
          .collection('coaches')
          .doc(coachID)
          .get();
      if (coachSnapshot.exists) {
        setState(() {
          isAllowed = coachSnapshot['isAllowed'] ?? false;
        });
      }
    } catch (e) {
      print('Failed to fetch isAllowed status: $e');
    }
  }

  Future<void> _checkPlayerAttendance(String playerId, String coachID) async {
    const int sessionprice = 100;
    const int doublesessionprice = 200;
    try {
      DocumentSnapshot playerSnapshot = await FirebaseFirestore.instance
          .collection('players')
          .doc(playerId)
          .get();

      if (playerSnapshot.exists) {
        int sessionPaid = playerSnapshot['sessionPaid'] ?? 0;
        bool isAllowedPlayer = playerSnapshot['isAllowedPlayer'] ?? false;

        if (sessionPaid <= 0) {
          if (isAllowedPlayer) {
            await _markAttendance(playerId, coachID, sessionprice);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No sessions left!"),
                backgroundColor: Colors.red,
              ),
            );

            bool? continueWithSingleSession = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('No sessions left'),
                  content: const Text(
                      'Do you want to continue with a single session at double the session price?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes'),
                    ),
                  ],
                );
              },
            );

            if (continueWithSingleSession == true) {
              await _markAttendance(playerId, coachID, doublesessionprice);
            } else {
              setState(() {
                scannedPlayerId = null;
              });
            }
          }
        } else {
          await _markAttendance(playerId, coachID, sessionprice);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAttendance(
      String playerId, String coachID, int sessionPrice) async {
    try {
      await CoachProvider().markFitnessAttendance(
        sessionPrice,
        playerId,
        coachID,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance marked successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showWorkoutDetails(Map<String, dynamic> historyItem) {
    final workout = historyItem['workout'] ?? 'No workout assigned yet';
    final workoutTemplateId = historyItem['workoutTemplateId'];
    final workoutExercises = historyItem['workoutExercises'];
    final isCustomWorkout = historyItem['isCustomWorkout'] ?? false;

    // For managing instruction overlays
    OverlayEntry? overlayEntry;

    // Function to show instructions in a floating box
    void showInstructionsOverlay(BuildContext context, String instructions) {
      // Remove any existing overlay first
      overlayEntry?.remove();

      overlayEntry = OverlayEntry(
        builder: (context) => Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              // Close the overlay when tapped anywhere
              overlayEntry?.remove();
              overlayEntry = null;
            },
            child: Container(
              color: Colors.black54, // Semi-transparent background
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(
                        maxWidth: 500,
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Instructions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  overlayEntry?.remove();
                                  overlayEntry = null;
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Text(
                                instructions,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                "Tap anywhere to close",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(overlayEntry!);
    }

    // Show either the stored exercises or fetch from database if only ID is stored
    if (workoutExercises != null) {
      // Directly show the exercises from attendance record
      _showWorkoutDialog(
          workout, workoutExercises, isCustomWorkout, showInstructionsOverlay);
    } else if (workoutTemplateId != null) {
      // Fetch template data from Firestore
      FirebaseFirestore.instance
          .collection('trainingTemplates')
          .doc(workoutTemplateId)
          .get()
          .then((doc) {
        if (doc.exists) {
          final templateData = doc.data() as Map<String, dynamic>;
          final exercises = templateData['exercises'] as List<dynamic>? ?? [];
          final description = templateData['description'] as String? ?? '';

          _showWorkoutDialog(
              workout,
              exercises.map((e) => e as Map<String, dynamic>).toList(),
              false,
              showInstructionsOverlay,
              description: description);
        } else {
          // Template not found
          _showWorkoutDialog(workout, [], false, showInstructionsOverlay);
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading workout: $error')),
        );
      });
    } else {
      // No template data available
      _showWorkoutDialog(workout, [], false, showInstructionsOverlay);
    }
  }

  void _showWorkoutDialog(
      String trainingName,
      List<dynamic> exercises,
      bool isCustomWorkout,
      Function(BuildContext, String) showInstructionsOverlay,
      {String description = ''}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with badge showing custom or template
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        trainingName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                    ),
                    if (isCustomWorkout)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Custom',
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Template',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                  ],
                ),

                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                // Exercises section title
                const Row(
                  children: [
                    Icon(Icons.fitness_center, color: mediumBlue, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Exercises',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                // Exercises list
                Expanded(
                  child: exercises.isEmpty
                      ? const Center(
                          child: Text(
                            'No exercises in this workout',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise =
                                exercises[index] as Map<String, dynamic>;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Exercise name
                                    Text(
                                      exercise['name']?.toString() ??
                                          'Unnamed Exercise',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: darkBlue,
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                    // Sets and reps
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                              'Sets: ${exercise['sets'] ?? 0}'),
                                          backgroundColor: Colors.blue[100],
                                        ),
                                        const SizedBox(width: 8),
                                        Chip(
                                          label: Text(
                                              'Reps: ${exercise['reps'] ?? 0}'),
                                          backgroundColor: Colors.green[100],
                                        ),
                                      ],
                                    ),

                                    // Instructions button
                                    if (exercise['instructions'] != null &&
                                        exercise['instructions']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Text(
                                            'Instructions: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              showInstructionsOverlay(
                                                  dialogContext,
                                                  exercise['instructions']
                                                      .toString());
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[100],
                                              foregroundColor: Colors.blue[900],
                                            ),
                                            child: const Text('View'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Close button
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final coachProvider = Provider.of<CoachProvider>(context);
    final theme = Theme.of(context);
    final String coachID = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        backgroundColor: mediumBlue,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [darkBlue, mediumBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome,',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                )),
            Text(
              coachProvider.coachname,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Provider.of<Authprovider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildCurrentTabContent(coachID, coachProvider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: mediumBlue,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Check-In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restore),
            label: 'Recovery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildCurrentTabContent(String coachID, CoachProvider coachProvider) {
    switch (_selectedIndex) {
      case 0:
        return _buildCheckInTab(coachID);
      case 1:
        return _buildAttendanceTab(coachID);
      case 2:
        return _buildRecoveryTab(coachID);
      case 3:
        return _buildHistoryTab(coachProvider);
      default:
        return const Center(child: Text('Tab not implemented'));
    }
  }

  // TAB 1: CHECK-IN
  Widget _buildCheckInTab(String coachID) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Coach Check-In"),
          _buildScanAttendanceSection(coachID),
          const SizedBox(height: 24),
          const SectionTitle(title: "Player Check-In"),
          _buildScanSection(context),
          const SizedBox(height: 16),
          if (scannedPlayerId != null) _buildScannedPlayerCard(),
        ],
      ),
    );
  }

  // TAB 2: ATTENDANCE
  Widget _buildAttendanceTab(String coachID) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Attendance Management"),
          _buildFitnessAttendanceSection(context, coachID),
          const SizedBox(height: 24),
          const SectionTitle(title: "Payment Management"),
          _buildPaymentSection(context),
        ],
      ),
    );
  }

  // TAB 3: RECOVERY
  Widget _buildRecoveryTab(String coachID) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Recovery Management"),
          _buildRecoveryAttendanceSection(context, coachID),
        ],
      ),
    );
  }

  // TAB 4: HISTORY
  Widget _buildHistoryTab(CoachProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Attendance History"),
          _buildHistoryList(provider),
        ],
      ),
    );
  }

  //coach check in and check out
  Widget _buildScanAttendanceSection(String coachid) {
    return ScanCard(
      title: 'Coach Scanning',
      buttonLabel: 'Scan Coach QR',
      onPressed: () async {
        try {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScanner()),
          );
          if (result != null) {
            setState(() => scannedData = result);
            if (result == "4344410d-cc61-47ef-b4ee-02406fe87f41") {
              await Provider.of<CoachProvider>(context, listen: false)
                  .handleCoachAttendance(coachid, 30.0);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Scan completed"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildScanSection(BuildContext context) {
    return ScanCard(
      title: 'Player Scanning',
      buttonLabel: 'Scan Player QR',
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScanner()),
        );
        if (result != null) {
          setState(() => scannedPlayerId = result);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Scan completed"),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  Widget _buildScannedPlayerCard() {
    return ScannedPlayerCard(
      onClear: () => setState(() {
        scannedPlayerId = null;
      }),
    );
  }

  Widget _buildFitnessAttendanceSection(BuildContext context, String coachID) {
    return AttendanceCard(
      scannedPlayerId: scannedPlayerId,
      onClearPlayer: () => setState(() {
        scannedPlayerId = null;
      }),
      onMarkAttendance: () async {
        await _checkPlayerAttendance(scannedPlayerId!, coachID);
      },
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return PaymentCard(
      scannedPlayerId: scannedPlayerId,
      amountController: _amountController,
      onAssignPayment: () async {
        if (_amountController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please enter an amount!"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        try {
          int amount = int.parse(_amountController.text);
          await CoachProvider().assignPayment(scannedPlayerId!, amount);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment assigned successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          _amountController.clear();
          setState(() {
            scannedPlayerId = null;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildRecoveryAttendanceSection(BuildContext context, String coachID) {
    return RecoveryCard(
      scannedPlayerId: scannedPlayerId,
      onClearPlayer: () => setState(() {
        scannedPlayerId = null;
      }),
      recoveryTypes: recoveryTypes,
      selectedRecoveryType: selectedRecoveryType,
      onRecoveryTypeChanged: (String? newValue) {
        setState(() {
          selectedRecoveryType = newValue;
        });
      },
      onMarkRecovery: () async {
        try {
          final amount = recoveryTypes[selectedRecoveryType]!;
          await CoachProvider().markRecoveryAttendance(
            scannedPlayerId!,
            coachID,
            amount,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Recovery session marked successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            selectedRecoveryType = null;
            scannedPlayerId = null;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      isAllowed: isAllowed,
    );
  }

  Widget _buildHistoryList(CoachProvider provider) {
    return FutureBuilder<void>(
      future: provider.loadReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          if (provider.reportsAttendace.isEmpty) {
            return const EmptyHistoryState();
          } else {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.reportsAttendace.length,
              itemBuilder: (context, index) {
                final historyItem = provider.reportsAttendace[index];
                return HistoryListItem(
                  historyItem: historyItem,
                  index: index,
                  onTap: () => _showWorkoutDetails(historyItem),
                );
              },
            );
          }
        }
      },
    );
  }
}
