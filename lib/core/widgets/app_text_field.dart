import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/theme_context_extension.dart';
import 'app_input_decoration.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.showPasswordToggle = false,
    this.fillColor,
    this.showEnabledBorder = true,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool showPasswordToggle;
  final Color? fillColor;
  final bool showEnabledBorder;
  final int maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colors.primaryText,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.showPasswordToggle ? _obscure : widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.showPasswordToggle ? 1 : widget.maxLines,
          decoration: appInputDecoration(
            context,
            hint: widget.hint,
            icon: widget.icon,
            fillColor: widget.fillColor,
            showEnabledBorder: widget.showEnabledBorder,
            suffix: widget.showPasswordToggle
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: colors.iconMuted,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}
