import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'scanned_player_card.dart';
import 'no_player_scanned_info.dart';

class RecoveryCard extends StatelessWidget {
  final String? scannedPlayerId;
  final VoidCallback? onClearPlayer;
  final Map<String, double> recoveryTypes;
  final String? selectedRecoveryType;
  final Function(String?)? onRecoveryTypeChanged;
  final VoidCallback onMarkRecovery;
  final bool isAllowed;

  const RecoveryCard({
    super.key,
    required this.scannedPlayerId,
    this.onClearPlayer,
    required this.recoveryTypes,
    required this.selectedRecoveryType,
    this.onRecoveryTypeChanged,
    required this.onMarkRecovery,
    required this.isAllowed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.restore, color: mediumBlue, size: 30),
                    SizedBox(width: 12),
                    Text(
                      'Recovery Session',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Track recovery sessions for players',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                if (scannedPlayerId != null)
                  ScannedPlayerCard(onClear: onClearPlayer)
                else
                  const NoPlayerScannedInfo(),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Recovery Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: recoveryTypes.keys.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        '$type (EGP ${recoveryTypes[type]?.toStringAsFixed(2)})',
                      ),
                    );
                  }).toList(),
                  onChanged: isAllowed ? onRecoveryTypeChanged : null,
                  value: selectedRecoveryType,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text(
                      'Mark Recovery Session',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(0, 50),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: (isAllowed &&
                            scannedPlayerId != null &&
                            selectedRecoveryType != null)
                        ? onMarkRecovery
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isAllowed)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, color: Colors.white, size: 50),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "You don't have permission to access recovery sessions",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
