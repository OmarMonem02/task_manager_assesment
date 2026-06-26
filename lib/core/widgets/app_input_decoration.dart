import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/theme_context_extension.dart';

InputDecoration appInputDecoration(
  BuildContext context, {
  required String hint,
  IconData? icon,
  Widget? suffix,
  Color? fillColor,
  bool showEnabledBorder = true,
}) {
  final colors = context.appColors;
  final scheme = context.colorScheme;

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: colors.iconMuted, fontSize: 14.sp),
    prefixIcon: icon != null
        ? Icon(icon, color: colors.iconMuted, size: 20.r)
        : null,
    suffixIcon: suffix,
    filled: true,
    fillColor: fillColor ?? colors.inputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide.none,
    ),
    enabledBorder: showEnabledBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colors.inputBorder, width: 1),
          )
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: scheme.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: scheme.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: scheme.error, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
  );
}
