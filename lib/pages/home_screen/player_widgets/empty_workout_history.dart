import 'package:flutter/material.dart';

class EmptyWorkoutHistory extends StatelessWidget {
  const EmptyWorkoutHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('No workout data available'),
    );
  }
}
