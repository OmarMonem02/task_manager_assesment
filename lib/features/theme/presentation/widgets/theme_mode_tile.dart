import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../cubit/theme_cubit.dart';

class ThemeModeTile extends StatelessWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode_outlined,
            color: context.colorScheme.primary,
            size: 24.r,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.primaryText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Switch between light and dark theme',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return Switch(
                value: mode == ThemeMode.dark,
                activeThumbColor: context.colorScheme.onPrimary,
                activeTrackColor: context.colorScheme.primary,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
        ],
      ),
    );
  }
}
