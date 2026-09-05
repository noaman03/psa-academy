import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddExercisePage extends StatefulWidget {
  @override
  _AddExercisePageState createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(nameController, 'Exercise Name'),
              const SizedBox(height: 12),
              _buildNumberField(setsController, 'Sets'),
              const SizedBox(height: 12),
              _buildNumberField(repsController, 'Reps'),
              const SizedBox(height: 12),
              _buildTextField(instructionsController, 'Instructions', lines: 3),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final sets = int.tryParse(setsController.text) ?? 0;
                    final reps = int.tryParse(repsController.text) ?? 0;
                    final instructions = instructionsController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Exercise name is required')),
                      );
                      return;
                    }

                    // Return the new exercise to the previous page
                    Navigator.pop(context, {
                      'name': name,
                      'sets': sets,
                      'reps': reps,
                      'instructions': instructions,
                    });
                  },
                  child: const Text('Add Exercise'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int lines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: lines,
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}
