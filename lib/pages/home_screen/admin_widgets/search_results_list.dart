import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psa_academy/pages/coach_details.dart';
import 'package:psa_academy/pages/player_details.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'package:async/async.dart';
import 'empty_state_widget.dart';

class SearchResultsList extends StatelessWidget {
  final String searchQuery;

  const SearchResultsList({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QuerySnapshot>>(
      stream: StreamZip([
        FirebaseFirestore.instance
            .collection('players')
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .snapshots(),
        FirebaseFirestore.instance
            .collection('coaches')
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .snapshots(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final playerData = snapshot.data![0].docs;
        final coachData = snapshot.data![1].docs;
        final combinedData = [...playerData, ...coachData];

        if (combinedData.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.search_off,
            message: 'No results found for "$searchQuery"',
            iconColor: Colors.grey[400],
          );
        }

        return ListView.builder(
          itemCount: combinedData.length,
          itemBuilder: (context, index) {
            final data = combinedData[index];
            final isPlayer = playerData.contains(data);
            final name = data['name'];
            final id = data.id;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPlayer
                      ? mediumBlue.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  child: Icon(
                    isPlayer ? Icons.person : Icons.sports,
                    color: isPlayer ? mediumBlue : Colors.orange,
                  ),
                ),
                title: Text(name),
                subtitle: Text(isPlayer ? 'Player' : 'Coach'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => isPlayer
                          ? PlayerDetails(playerID: id)
                          : CoachDetails(coachiD: id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
