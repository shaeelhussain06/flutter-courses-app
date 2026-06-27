import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/course_controller.dart';
import 'package:flutter_app/models/course_model.dart';

/// Shared form screen for both Add (Create) and Edit (Update) operations.
/// Pre-fills existing data when [existingCourse] is provided.
class CourseFormScreen extends StatefulWidget {
  final CourseController controller;
  final CourseModel? existingCourse;

  const CourseFormScreen({
    super.key,
    required this.controller,
    this.existingCourse,
  });

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  bool get _isEditing => widget.existingCourse != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.existingCourse?.title ?? '',
    );

    _bodyController = TextEditingController(
      text: widget.existingCourse?.body ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    bool success;

    if (_isEditing) {
      success = await widget.controller.editCourse(
        course: widget.existingCourse!,
        title: _titleController.text.trim(),
        description: _bodyController.text.trim(),
      );
    } else {
      success = await widget.controller.addCourse(
        title: _titleController.text.trim(),
        description: _bodyController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.controller.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final bool isLoading = _isEditing
            ? widget.controller.isUpdating
            : widget.controller.isAdding;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Course' : 'Add Course'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.indigo.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _isEditing
                              ? Icons.edit_note
                              : Icons.add_circle_outline,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Course Title',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.words,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'e.g. Introduction to Flutter',
                        prefixIcon: const Icon(Icons.school_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Course title is required';
                        }

                        if (value.trim().length < 3) {
                          return 'Title must be at least 3 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Description',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _bodyController,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Enter a brief course description...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }

                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(_isEditing ? Icons.save : Icons.add),
                        label: Text(
                          isLoading
                              ? 'Please wait...'
                              : (_isEditing ? 'Save Changes' : 'Add Course'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}