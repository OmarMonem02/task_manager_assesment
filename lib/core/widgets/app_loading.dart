import 'package:flutter/material.dart';
import '../theme/theme_context_extension.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.colorScheme.primary),
    );
  }
}
