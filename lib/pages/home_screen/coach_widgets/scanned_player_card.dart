import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class ScannedPlayerCard extends StatelessWidget {
  final VoidCallback? onClear;

  const ScannedPlayerCard({
    super.key,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.person, color: mediumBlue),
        title: const Text(
          'Scanned Player',
          style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),
        ),
        subtitle: const Text('Scan completed', overflow: TextOverflow.ellipsis),
        trailing: onClear != null
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}
