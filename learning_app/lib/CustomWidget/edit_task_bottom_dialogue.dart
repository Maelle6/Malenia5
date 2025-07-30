import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:learning_app/Constants/app_color.dart';
import 'package:learning_app/Constants/constant.dart';
import 'package:learning_app/blocs/task_CRUD_operation_bloc/task_crud_operation_bloc.dart';
import 'package:task_repository/task_repository.dart';

class EditTaskDialog extends StatefulWidget {
  final Task task;
  final String userId;

  const EditTaskDialog({super.key, required this.task, required this.userId});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late DateTime _dueDate;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the values with the task data passed from the widget
    _title = widget.task.title;
    _description = widget.task.description;
    _dueDate = widget.task.dueDate;

    // Initialize the controllers with current task data
    _titleController.text = _title;
    _descriptionController.text = _description;
    _dueDateController.text = DateFormat('yyyy-MM-dd').format(_dueDate);

    // Add listeners to update the state for character tracking
    _titleController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(_dueDate);
      });
    }
  }

  void _updateTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTask = widget.task.copyWith(
        title: _title,
        description: _description,
        dueDate: _dueDate,
      );

      context
          .read<TaskCrudOperationBloc>()
          .add(UpdateTask(updatedTask, widget.userId));
      Navigator.pop(context);
    }
  }

  void _cancelEdit() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16, right: 16, left: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(editTaskImg),
                  const SizedBox(height: 30),
                  // Title input field
                  TextFormField(
                    controller: _titleController,
                    maxLength: 50,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSaved: (value) => _title = value!,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 15),
                  // Description input field
                  TextFormField(
                    controller: _descriptionController,
                    maxLength: 150,
                    decoration: InputDecoration(
                      labelText: 'Task Description',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSaved: (value) => _description = value!,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 15),
                  // Due Date input field
                  TextFormField(
                    controller: _dueDateController,
                    readOnly: true,
                    onTap: () => _selectDueDate(context),
                    decoration: InputDecoration(
                      labelText: 'Due Date (Tap to select)',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select a due date'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _cancelEdit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      backgroundColor: AppColors.purple,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      backgroundColor: AppColors.purple,
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
