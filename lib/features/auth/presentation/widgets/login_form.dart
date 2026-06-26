import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'auth_form_footer.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              username: _usernameController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Username',
            hint: 'Enter your username',
            controller: _usernameController,
            icon: Icons.person_outline,
            validator: (value) => Validators.required(value, 'your username'),
          ),
          SizedBox(height: 20.h),
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            icon: Icons.lock_outline,
            showPasswordToggle: true,
            validator: (value) => Validators.required(value, 'your password'),
          ),
          SizedBox(height: 40.h),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return AppButton(
                label: 'Sign In',
                isLoading: state is AuthLoading,
                onPressed: () => _onLogin(context),
              );
            },
          ),
          SizedBox(height: 14.h),
          const AuthFormFooter(
            prompt: 'Don\'t have an account?',
            actionLabel: 'Sign up',
            route: AppRouter.register,
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              'Use this dummy credentials to login:',
              style: TextStyle(fontSize: 12.sp, color: colors.secondaryText),
            ),
          ),
          Center(
            child: Text(
              'emilys / emilyspass',
              style: TextStyle(fontSize: 12.sp, color: colors.secondaryText),
            ),
          ),
          Center(
            child: Text(
              'emmaj  / emmajpass',
              style: TextStyle(fontSize: 12.sp, color: colors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}
