import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input_decoration.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({
    super.key,
    required this.projectId,
    required this.onAdd,
  });

  final int projectId;
  final void Function(String title, String priority) onAdd;

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _priority = 'Medium';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(_controller.text.trim(), _priority);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBottomSheet(
      title: 'Add New Task',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: appInputDecoration(
                context,
                hint: 'Task title...',
                fillColor: colors.scaffoldBackground,
                showEnabledBorder: false,
              ),
              validator: (value) => Validators.required(value, 'a task title'),
            ),
            SizedBox(height: 12.h),
            Text(
              'Priority',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: colors.secondaryText,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: appInputDecoration(
                context,
                hint: 'Select priority',
                fillColor: colors.scaffoldBackground,
                showEnabledBorder: false,
              ),
              items: const [
                DropdownMenuItem(value: 'Low', child: Text('Low')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'High', child: Text('High')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
            SizedBox(height: 16.h),
            AppButton(label: 'Add Task', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
