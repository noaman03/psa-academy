import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class AddExpenseDialog extends StatefulWidget {
  final List<String> expenseOptions;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final FocusNode titleFocusNode;
  final bool expenseOptionsShow;
  final Function(bool) onExpenseOptionsShowChanged;

  const AddExpenseDialog({
    super.key,
    required this.expenseOptions,
    required this.titleController,
    required this.amountController,
    required this.titleFocusNode,
    required this.expenseOptionsShow,
    required this.onExpenseOptionsShowChanged,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.add_circle_outline, color: mediumBlue),
          SizedBox(width: 8),
          Text('Add Expense'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.titleController,
              focusNode: widget.titleFocusNode,
              decoration: InputDecoration(
                labelText: 'Expense Title',
                prefixIcon: const Icon(Icons.title, color: mediumBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: mediumBlue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.expenseOptionsShow) ...[
              const Text(
                'Suggested Categories',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.expenseOptions.map((option) {
                  return ChoiceChip(
                    label: Text(option),
                    selected: widget.titleController.text == option,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          widget.titleController.text = option;
                        });
                      }
                    },
                    selectedColor: mediumBlue.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: widget.titleController.text == option
                          ? mediumBlue
                          : darkBlue,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: widget.amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (EGP)',
                prefixIcon: const Icon(Icons.attach_money, color: mediumBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: mediumBlue, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.titleController.clear();
            widget.amountController.clear();
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: mediumBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            if (widget.titleController.text.isNotEmpty &&
                widget.amountController.text.isNotEmpty) {
              try {
                await FirebaseFirestore.instance.collection('expences').add({
                  'title': widget.titleController.text,
                  'amount': int.parse(widget.amountController.text),
                  'date': Timestamp.now(),
                });

                widget.titleController.clear();
                widget.amountController.clear();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Add Expense'),
        ),
      ],
    );
  }
}
