import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_context_extension.dart';

InputDecoration inputDecoration(
  BuildContext context, {
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  final colors = context.appColors;
  final scheme = context.colorScheme;

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: colors.iconMuted, fontSize: 14.sp),
    prefixIcon: Icon(icon, color: colors.iconMuted, size: 20.r),
    suffixIcon: suffix,
    filled: true,
    fillColor: colors.inputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: colors.inputBorder, width: 1),
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

InputDecoration sheetInputDecoration(BuildContext context, String hint) {
  final colors = context.appColors;
  final scheme = context.colorScheme;

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: colors.iconMuted, fontSize: 14.sp),
    filled: true,
    fillColor: colors.scaffoldBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: scheme.primary, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
  );
}
