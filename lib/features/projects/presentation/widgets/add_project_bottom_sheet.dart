import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input_decoration.dart';

class AddProjectBottomSheet extends StatefulWidget {
  const AddProjectBottomSheet({super.key, required this.onAdd});

  final void Function(String name, String description) onAdd;

  @override
  State<AddProjectBottomSheet> createState() => _AddProjectBottomSheetState();
}

class _AddProjectBottomSheetState extends State<AddProjectBottomSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBottomSheet(
      title: 'Create New Project',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: appInputDecoration(
                context,
                hint: 'Project name...',
                fillColor: colors.scaffoldBackground,
                showEnabledBorder: false,
              ),
              validator: (value) => Validators.required(value, 'a project name'),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: appInputDecoration(
                context,
                hint: 'Description (optional)',
                fillColor: colors.scaffoldBackground,
                showEnabledBorder: false,
              ),
            ),
            SizedBox(height: 16.h),
            AppButton(label: 'Create Project', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
