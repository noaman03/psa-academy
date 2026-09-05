import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/pages/login_screen.dart';
import 'package:psa_academy/service/provider/authProvider.dart';
import 'package:psa_academy/service/provider/playerProvider.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player_widgets/player_widgets.dart';

class PlayerHome extends StatefulWidget {
  const PlayerHome({super.key});

  @override
  _PlayerHomeState createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> {
  // ignore: unused_field
  late Future<void> _loadPlayerDataFuture;
  late String _qrData = '';
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final String playerId = FirebaseAuth.instance.currentUser!.uid;
    _loadPlayerDataFuture = playerProvider.loadPlayerData(playerId);
    _qrData = playerId;
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final theme = Theme.of(context);

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
        title: Row(
          children: [
            const Image(
                image: AssetImage('assets/images/mainNOBGFW.png'),
                width: 40,
                height: 40),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back,',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  playerProvider.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              PlayerBalanceCard(
                balance: playerProvider.balance.toDouble(),
                qrData: _qrData,
              ),
              const SizedBox(height: 24),

              // Progress Section
              Text(
                'Training Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              PlayerProgressSection(
                sessionsPaid: playerProvider.sessionsPaid,
                sessionsAttended: playerProvider.sessionsAttended,
              ),
              const SizedBox(height: 24),

              // History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment History',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: darkBlue),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildHistoryList(playerProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(PlayerProvider provider) {
    final String playerId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('attendance')
          .where('playerId', isEqualTo: playerId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyWorkoutHistory();
        }

        final attendanceDocs = snapshot.data!.docs;

        // Group attendance records by date
        final Map<String, List<QueryDocumentSnapshot>> groupedDocs = {};
        for (var doc in attendanceDocs) {
          final Timestamp timestamp = doc['date'];
          final DateTime dateTime = timestamp.toDate();
          final formattedDate = DateFormat('MMMM dd, yyyy').format(dateTime);

          if (!groupedDocs.containsKey(formattedDate)) {
            groupedDocs[formattedDate] = [];
          }
          groupedDocs[formattedDate]!.add(doc);
        }

        // Sort the grouped dates in descending order
        final sortedDates = groupedDocs.keys.toList()
          ..sort((a, b) => DateFormat('MMMM dd, yyyy')
              .parse(b)
              .compareTo(DateFormat('MMMM dd, yyyy').parse(a)));

        // Flatten the grouped docs into a single list
        final List<QueryDocumentSnapshot> flattenedDocs = [];
        for (var date in sortedDates) {
          flattenedDocs.addAll(groupedDocs[date]!);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: flattenedDocs.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final attendanceDoc = flattenedDocs[index];
            return WorkoutHistoryItem(
              attendanceDoc: attendanceDoc,
              index: index,
              onTap: () => _showWorkoutDetails(attendanceDoc),
            );
          },
        );
      },
    );
  }

  void _showWorkoutDetails(DocumentSnapshot attendanceDoc) {
    final workout = attendanceDoc['workout'] ?? 'No workout assigned';
    final workoutTemplateId = attendanceDoc['workoutTemplateId'];
    final workoutExercises =
        attendanceDoc['workoutExercises']; // If stored directly in attendance
    final isCustomWorkout = attendanceDoc['isCustomWorkout'] ?? false;

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
                // Header with workout name and status badge
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
                              elevation: 2,
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mediumBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
