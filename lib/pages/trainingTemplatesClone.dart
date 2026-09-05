// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/service/provider/adminProvider.dart';

class TrainingTemplatesClonePage extends StatefulWidget {
  final String attendanceId;
  final String playerId;
  final Timestamp date;
  final String currentWorkout;

  const TrainingTemplatesClonePage({
    Key? key,
    required this.attendanceId,
    required this.playerId,
    required this.date,
    required this.currentWorkout,
  }) : super(key: key);

  @override
  _TrainingTemplatesClonePageState createState() =>
      _TrainingTemplatesClonePageState();
}

class _TrainingTemplatesClonePageState
    extends State<TrainingTemplatesClonePage> {
  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Training Template'),
            Text(
              'Current: ${widget.currentWorkout}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
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
                      // Edit and assign button (replacing the eye icon)
                      IconButton(
                        onPressed: () {
                          _createTemporaryTemplate(template);
                        },
                        icon: const Icon(Icons.edit_note,
                            color: Colors.blueAccent),
                        tooltip: 'Edit and assign',
                      ),
                      // Direct assign button
                      IconButton(
                        onPressed: () {
                          _assignWorkoutTemplate(trainingName, template.id);
                        },
                        icon: const Icon(Icons.assignment_turned_in,
                            color: Colors.green),
                        tooltip: 'Assign without editing',
                      ),
                    ],
                  ),
                  onTap: () {
                    // Tap on the card also assigns the template
                    _assignWorkoutTemplate(trainingName, template.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _assignWorkoutTemplate(String templateName, String templateId) async {
    try {
      // Get the template to have all its data
      DocumentSnapshot templateDoc = await FirebaseFirestore.instance
          .collection('trainingTemplates')
          .doc(templateId)
          .get();

      Map<String, dynamic> templateData =
          templateDoc.data() as Map<String, dynamic>;

      // Update the workout in Firestore
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.attendanceId)
          .update({
        'workout': templateName,
        'workoutTemplateId': templateId,
        'workoutDescription': templateData['description'] ?? '',
        'workoutExercises': templateData['exercises'] ?? [],
        'isCustomWorkout': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template "$templateName" assigned as workout')),
      );

      // Return to previous screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning template: $e')),
      );
    }
  }

  void _showEditExerciseDialog(
      BuildContext context,
      void Function(void Function()) setState,
      List<Map<String, dynamic>> exercises,
      int index) {
    final exercise = exercises[index];
    final String? exerciseId = exercise['exerciseId']?.toString();
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

  void _createTemporaryTemplate(QueryDocumentSnapshot template) {
    final data = template.data() as Map<String, dynamic>;
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    // Create deep copy of the template data
    final tempName = data['trainingName'] ?? 'Unnamed Training';
    final tempDescription = data['description'] ?? '';

    // Deep copy of exercises
    List<Map<String, dynamic>> tempExercises = [];
    final dynamicExercises = data['exercises'] as List<dynamic>?;
    if (dynamicExercises != null) {
      for (var exercise in dynamicExercises) {
        final Map<String, dynamic> exerciseMap =
            Map<String, dynamic>.from(exercise as Map<String, dynamic>);
        tempExercises.add(exerciseMap);
      }
    }

    // Show edit dialog with the copy
    _showEditTempTemplateDialog(tempName, tempDescription, tempExercises);
  }

  void _showEditTempTemplateDialog(String originalName,
      String originalDescription, List<Map<String, dynamic>> exercises) {
    final TextEditingController trainingNameController = TextEditingController(
      text: "$originalName (Custom)",
    );
    final TextEditingController descriptionController = TextEditingController(
      text: originalDescription,
    );

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Dialog(
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Customize Workout Template',
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

                            // Assign this custom template directly to attendance
                            // No need to save it in trainingTemplates collection
                            try {
                              await FirebaseFirestore.instance
                                  .collection('attendance')
                                  .doc(widget.attendanceId)
                                  .update({
                                'workout': trainingName,
                                'workoutDescription': description,
                                'workoutExercises': exercises,
                                'isCustomWorkout': true,
                                'updatedAt': FieldValue.serverTimestamp(),
                              });

                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Custom workout "$trainingName" assigned')),
                              );
                              Navigator.pop(
                                  context); // Return to previous screen
                            } catch (e) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error assigning custom workout: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Assign Custom Workout',
                              style: TextStyle(color: Colors.white)),
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
}
