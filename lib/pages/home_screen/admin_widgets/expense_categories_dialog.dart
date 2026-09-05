import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psa_academy/utils/constants/colors.dart';

class ExpenseCategoriesDialog extends StatefulWidget {
  final List<String> expenseOptions;
  final Function(List<String>) onCategoriesChanged;

  const ExpenseCategoriesDialog({
    super.key,
    required this.expenseOptions,
    required this.onCategoriesChanged,
  });

  @override
  State<ExpenseCategoriesDialog> createState() =>
      _ExpenseCategoriesDialogState();
}

class _ExpenseCategoriesDialogState extends State<ExpenseCategoriesDialog> {
  final TextEditingController _categoryController = TextEditingController();
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.expenseOptions);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveCategories() async {
    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('expenseCategories')
          .set({
        'categories': _categories,
        'lastUpdated': Timestamp.now(),
      });
      widget.onCategoriesChanged(_categories);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving categories: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addCategory() {
    if (_categoryController.text.trim().isNotEmpty) {
      setState(() {
        _categories.add(_categoryController.text.trim());
        _saveCategories();
        _categoryController.clear();
      });
    }
  }

  void _editCategory(int index) {
    final TextEditingController editController = TextEditingController(
      text: _categories[index],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  setState(() {
                    _categories[index] = editController.text.trim();
                    _saveCategories();
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mediumBlue,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(int index) {
    setState(() {
      _categories.removeAt(index);
      _saveCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.category, color: mediumBlue),
          const SizedBox(width: 10),
          const Text('Expense Categories'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'New Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add_circle, color: mediumBlue),
                  onPressed: _addCategory,
                ),
              ),
              onSubmitted: (_) => _addCategory(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Current Categories:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _categories.isEmpty
                  ? const Center(
                      child: Text('No categories added yet'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(_categories[index]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _editCategory(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteCategory(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
