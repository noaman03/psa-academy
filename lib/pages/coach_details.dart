import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CoachDetails extends StatefulWidget {
  const CoachDetails({required this.coachiD, super.key});
  final String coachiD;

  @override
  State<CoachDetails> createState() => _CoachDetailsState();
}

class _CoachDetailsState extends State<CoachDetails> {
  late Future<DocumentSnapshot> _coachDataFuture;
  late Future<QuerySnapshot> _attendanceHistoryFuture;
  bool isAllowed = false;

  @override
  void initState() {
    super.initState();
    _coachDataFuture = FirebaseFirestore.instance
        .collection('coaches')
        .doc(widget.coachiD)
        .get();
    _attendanceHistoryFuture = FirebaseFirestore.instance
        .collection('coachWorkSessions')
        .where('coachId', isEqualTo: widget.coachiD)
        .get();
    _fetchIsAllowedStatus();
  }

  Future<void> _fetchIsAllowedStatus() async {
    try {
      final coachDoc =
          FirebaseFirestore.instance.collection('coaches').doc(widget.coachiD);
      final coachSnapshot = await coachDoc.get();
      if (coachSnapshot.exists) {
        setState(() {
          isAllowed = coachSnapshot['isAllowed'] ?? false;
        });
      }
    } catch (e) {
      print('Failed to fetch isAllowed status: $e');
    }
  }

  Future<void> _toggleIsAllowed() async {
    try {
      final coachDoc =
          FirebaseFirestore.instance.collection('coaches').doc(widget.coachiD);
      final currentStatus = isAllowed;
      await coachDoc.update({'isAllowed': !currentStatus});
      setState(() {
        isAllowed = !currentStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('isAllowed status updated to ${!currentStatus}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Failed to update isAllowed status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update isAllowed status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        backgroundColor: mediumBlue,
        elevation: 0,
        title: const Text(
          'Coach Details',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _coachDataFuture = FirebaseFirestore.instance
                    .collection('coaches')
                    .doc(widget.coachiD)
                    .get();
                _attendanceHistoryFuture = FirebaseFirestore.instance
                    .collection('coachWorkSessions')
                    .where('coachId', isEqualTo: widget.coachiD)
                    .get();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _coachDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Coach not found'));
          } else {
            final coachData = snapshot.data!.data() as Map<String, dynamic>;
            final coachName = coachData['name'];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coach Name and Stats
                    _buildCoachHeader(coachName),
                    const SizedBox(height: 24),

                    // Attendance History Section
                    Text(
                      'Attendance History',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAttendanceHistory(),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCoachHeader(String coachName) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: mediumBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coachName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<QuerySnapshot>(
              future: _attendanceHistoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.white);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No sessions yet',
                      style: TextStyle(color: Colors.white));
                } else {
                  final totalHours = snapshot.data!.docs.fold(
                      0.0, (sum, doc) => sum + (doc['hoursWorked'] as double));
                  final totalSessions = snapshot.data!.docs.length;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        icon: Icons.access_time,
                        label: 'Total Hours',
                        value: totalHours.toStringAsFixed(1),
                      ),
                      _buildStatItem(
                        icon: Icons.event,
                        label: 'Total Sessions',
                        value: totalSessions.toString(),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            // Smooth Custom Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recovery Coach',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                ToggleSwitch(
                  minWidth: 90.0,
                  initialLabelIndex: isAllowed ? 0 : 1,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  totalSwitches: 2,
                  labels: const ['Yes', 'No'],
                  icons: const [Icons.done, Icons.clear],
                  activeBgColors: const [
                    [Colors.green],
                    [Colors.pink]
                  ],
                  onToggle: (index) async {
                    await _toggleIsAllowed();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      {required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceHistory() {
    return FutureBuilder<QuerySnapshot>(
      future: _attendanceHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No attendance history found',
              style: TextStyle(color: darkBlue),
            ),
          );
        } else {
          final attendanceHistory = snapshot.data!.docs;

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attendanceHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final historyItem = attendanceHistory[index];
              final Timestamp timestamp = historyItem['checkIn'];
              final DateTime dateTime = timestamp.toDate();
              final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
              final hoursWorked = historyItem['hoursWorked'];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mediumBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: mediumBlue,
                    ),
                  ),
                  title: Text(
                    'Session ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  subtitle: Text(formattedDate),
                  trailing: Text(
                    '$hoursWorked hours',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mediumBlue,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
