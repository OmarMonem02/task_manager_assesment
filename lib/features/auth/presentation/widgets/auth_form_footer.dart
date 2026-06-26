import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_context_extension.dart';

class AuthFormFooter extends StatelessWidget {
  const AuthFormFooter({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.route,
  });

  final String prompt;
  final String actionLabel;
  final String route;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = context.colorScheme;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prompt,
            style: TextStyle(fontSize: 12.sp, color: colors.secondaryText),
          ),
          TextButton(
            onPressed: () => context.go(route),
            child: Text(
              actionLabel,
              style: TextStyle(color: scheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
