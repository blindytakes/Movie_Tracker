cat > lib/screens/add_entry_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/viewing_provider.dart';
import '../models/viewing_entry.dart';

class AddEntryScreen extends StatefulWidget {
  final ViewingEntry? entryToEdit;

  const AddEntryScreen({super.key, this.entryToEdit});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'movie';
  DateTime _selectedDate = DateTime.now();
  int? _selectedRating;

  bool get _isEditing => widget.entryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFieldsForEditing();
    }
  }

  void _populateFieldsForEditing() {
    final entry = widget.entryToEdit!;
    _titleController.text = entry.title;
    _notesController.text = entry.notes ?? '';
    _selectedType = entry.type;
    _selectedDate = entry.dateWatched;
    _selectedRating = entry.rating;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'Add New Entry'),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: Text(
              _isEditing ? 'UPDATE' : 'SAVE',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Consumer<ViewingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                      hintText: 'Enter movie or TV show title',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Type Selection
                  Text(
                    'Type *',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Movie'),
                          value: 'movie',
                          groupValue: _selectedType,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('TV Show'),
                          value: 'tv',
                          groupValue: _selectedType,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date Selection
                  Text(
                    'Date Watched *',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 16),
                          Text(
                            DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rating Selection
                  Text(
                    'Rating (Optional)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedRating = null;
                          });
                        },
                        child: Text(
                          'No Rating',
                          style: TextStyle(
                            color: _selectedRating == null ? Theme.of(context).primaryColor : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ...List.generate(5, (index) {
                        final rating = index + 1;
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedRating = rating;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            color: _selectedRating != null && _selectedRating! >= rating
                                ? Colors.amber
                                : Colors.grey[300],
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Add your thoughts, review, or any notes...',
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Error Message
                  if (provider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<ViewingProvider>(context, listen: false);

    if (_isEditing) {
      // Update existing entry
      final updatedEntry = widget.entryToEdit!.copyWith(
        title: _titleController.text.trim(),
        type: _selectedType,
        dateWatched: _selectedDate,
        rating: _selectedRating,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
      await provider.updateViewingEntry(updatedEntry);
    } else {
      // Add new entry
      await provider.addViewingEntry(
        title: _titleController.text.trim(),
        type: _selectedType,
        dateWatched: _selectedDate,
        rating: _selectedRating,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
    }

    if (provider.error == null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Entry updated successfully!' : 'Entry added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
EOF