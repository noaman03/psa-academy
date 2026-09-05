import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for FilteringTextInputFormatter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/service/provider/adminProvider.dart';

class TrainingTemplatesPage extends StatefulWidget {
  @override
  _TrainingTemplatesPageState createState() => _TrainingTemplatesPageState();
}

class _TrainingTemplatesPageState extends State<TrainingTemplatesPage> {
  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Templates'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trainingTemplates')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No training templates available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final templates = snapshot.data!.docs;

          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final data = template.data() as Map<String, dynamic>;
              final trainingName = data['trainingName'] ?? 'Unnamed Training';
              final description = data['description'] ?? '';

              return Card(
                margin: const EdgeInsets.all(12.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    trainingName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Show template details in a dialog
                          _showTemplateDetailsDialog(context, template);
                        },
                        icon: const Icon(Icons.remove_red_eye_outlined,
                            color: Colors.blueAccent),
                      ),
                      IconButton(
                        onPressed: () {
                          // Delete the template
                          FirebaseFirestore.instance
                              .collection('trainingTemplates')
                              .doc(template.id)
                              .delete();
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                      IconButton(
                          onPressed: () {
                            _showEditTemplateDialog(
                                context, template, adminProvider);
                          },
                          icon: Icon(Icons.edit, color: Colors.blueAccent))
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditTemplateDialog(context, null, adminProvider);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditTemplateDialog(BuildContext context,
      QueryDocumentSnapshot? template, AdminProvider adminProvider) {
    final TextEditingController trainingNameController = TextEditingController(
      text: template != null ? template['trainingName']?.toString() : '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: template != null ? template['description']?.toString() : '',
    );

    List<Map<String, dynamic>> exercises = [];
    if (template != null) {
      final dynamicExercises = template['exercises'] as List<dynamic>?;
      if (dynamicExercises != null) {
        exercises = dynamicExercises
            .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
            .toList();
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Dialog(
              // Use Dialog instead of AlertDialog for more flexible sizing
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxWidth: 600, // Maximum width
                  maxHeight: MediaQuery.of(context).size.height *
                      0.8, // Maximum height
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      template != null ? 'Edit Template' : 'Add Template',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: trainingNameController,
                              decoration: const InputDecoration(
                                labelText: 'Training Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Exercises',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: exercises.length,
                              itemBuilder: (context, index) {
                                final exercise = exercises[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    title: Text(exercise['name']?.toString() ??
                                        'Unnamed Exercise'),
                                    subtitle: Text(
                                      'Sets: ${exercise['sets']}, Reps: ${exercise['reps']}',
                                    ),
                                    trailing: SizedBox(
                                      width: 100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blueAccent),
                                              onPressed: () {
                                                _showEditExerciseDialog(
                                                    dialogContext,
                                                    setState,
                                                    exercises,
                                                    index);
                                              }),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                exercises.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _showAddExerciseDialog(
                                    dialogContext, setState, exercises);
                              },
                              icon: const Icon(Icons.add,
                                  color: Colors.blueAccent),
                              label: const Text('Add Exercise'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final trainingName =
                                trainingNameController.text.trim();
                            final description =
                                descriptionController.text.trim();

                            if (trainingName.isEmpty) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Training name is required.')),
                              );
                              return;
                            }

                            final data = {
                              'trainingName': trainingName,
                              'description': description,
                              'exercises': exercises,
                            };

                            try {
                              if (template == null) {
                                await FirebaseFirestore.instance
                                    .collection('trainingTemplates')
                                    .add(data);
                              } else {
                                await FirebaseFirestore.instance
                                    .collection('trainingTemplates')
                                    .doc(template.id)
                                    .update(data);
                              }
                              Navigator.of(dialogContext).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                    content: Text('Error saving template: $e')),
                              );
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddExerciseDialog(
      BuildContext context,
      void Function(void Function()) setState,
      List<Map<String, dynamic>> exercises) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController setsController = TextEditingController();
    final TextEditingController repsController = TextEditingController();
    final TextEditingController instructionsController =
        TextEditingController();
    final AdminProvider adminProvider =
        Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: setsController,
                  decoration: const InputDecoration(
                    labelText: 'Sets',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Instructions',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final sets = int.tryParse(setsController.text.trim()) ?? 0;
                final reps = int.tryParse(repsController.text.trim()) ?? 0;
                final instructions = instructionsController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Exercise name is required.')),
                  );
                  return;
                }

                // In the ElevatedButton onPressed handler
                String exerciseId = await adminProvider.addtrainingexercise(
                    name, instructions, sets, reps);

                setState(() {
                  exercises.add({
                    'name': name,
                    'sets': sets,
                    'reps': reps,
                    'instructions': instructions,
                    'exerciseId': exerciseId,
                  });
                });

                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditExerciseDialog(
      BuildContext context,
      void Function(void Function()) setState,
      List<Map<String, dynamic>> exercises,
      int index) {
    final exercise = exercises[index];
    final String? exerciseId = exercise['exerciseId']?.toString();
    // ignore: unused_local_variable
    final AdminProvider adminProvider =
        Provider.of<AdminProvider>(context, listen: false);

    final TextEditingController nameController = TextEditingController(
      text: exercise['name']?.toString() ?? '',
    );
    final TextEditingController setsController = TextEditingController(
      text: exercise['sets']?.toString() ?? '',
    );
    final TextEditingController repsController = TextEditingController(
      text: exercise['reps']?.toString() ?? '',
    );
    final TextEditingController instructionsController = TextEditingController(
      text: exercise['instructions']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Edit Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: setsController,
                  decoration: const InputDecoration(
                    labelText: 'Sets',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Instructions',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final sets = int.tryParse(setsController.text.trim()) ?? 0;
                final reps = int.tryParse(repsController.text.trim()) ?? 0;
                final instructions = instructionsController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Exercise name is required.')),
                  );
                  return;
                }

                try {
                  // Update in Firestore if it has an exerciseId
                  if (exerciseId != null) {
                    await FirebaseFirestore.instance
                        .collection('exercises')
                        .doc(exerciseId)
                        .update({
                      'name': name,
                      'sets': sets,
                      'reps': reps,
                      'instructions': instructions,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                  } else {
                    // If there's no exerciseId, create a new one in Firestore
                    DocumentReference exerciseRef = await FirebaseFirestore
                        .instance
                        .collection('exercises')
                        .add({
                      'name': name,
                      'sets': sets,
                      'reps': reps,
                      'instructions': instructions,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    String newExerciseId = exerciseRef.id;
                    await exerciseRef.update({'exerciseId': newExerciseId});

                    // Make sure to use the new exerciseId
                    exercise['exerciseId'] = newExerciseId;
                  }

                  // Update in local state
                  setState(() {
                    exercises[index] = {
                      'name': name,
                      'sets': sets,
                      'reps': reps,
                      'instructions': instructions,
                      'exerciseId': exerciseId ??
                          exercise['exerciseId'], // Preserve the exerciseId
                    };
                  });

                  Navigator.of(dialogContext).pop();
                } catch (e) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Error updating exercise: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showTemplateDetailsDialog(
      BuildContext context, QueryDocumentSnapshot template) {
    final data = template.data() as Map<String, dynamic>;
    final trainingName = data['trainingName'] ?? 'Unnamed Training';
    final description = data['description'] ?? '';

    // Get exercises list
    List<Map<String, dynamic>> exercises = [];
    final dynamicExercises = data['exercises'] as List<dynamic>?;
    if (dynamicExercises != null) {
      exercises = dynamicExercises
          .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
          .toList();
    }

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
                      width: MediaQuery.of(context).size.width * 0.85,
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

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async {
            // Clean up overlay if it exists when dialog is closed
            if (overlayEntry != null) {
              overlayEntry?.remove();
              overlayEntry = null;
            }
            return true;
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with training name
                  Text(
                    trainingName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    // Description
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  // Exercises section title
                  const Text(
                    'Exercises',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Exercises list
                  Expanded(
                    child: exercises.isEmpty
                        ? const Center(child: Text('No exercises added'))
                        : ListView.builder(
                            itemCount: exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = exercises[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Exercise name
                                      Text(
                                        exercise['name']?.toString() ??
                                            'Unnamed Exercise',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
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

                                      // Instructions if available
                                      if (exercise['instructions'] != null &&
                                          exercise['instructions']
                                              .toString()
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Instructions:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showInstructionsOverlay(
                                                context,
                                                exercise['instructions']
                                                    .toString());
                                          },
                                          child: Text(
                                            exercise['instructions'].toString(),
                                            style: const TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
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
          ),
        );
      },
    );
  }
}
