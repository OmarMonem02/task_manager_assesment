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

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterRequested(
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
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
          SizedBox(height: 40.h),
          Text(
            'Welcome to Task Manager 👋',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            textAlign: TextAlign.center,
            'Create an account to start managing your tasks',
            style: TextStyle(fontSize: 16.sp, color: colors.secondaryText),
          ),
          SizedBox(height: 28.h),
          AppTextField(
            label: 'Username',
            hint: 'Enter your username',
            controller: _usernameController,
            icon: Icons.person_outline,
            validator: (value) => Validators.required(value, 'your username'),
          ),
          SizedBox(height: 16.h),
          AppTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => Validators.required(value, 'your email'),
          ),
          SizedBox(height: 16.h),
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            icon: Icons.lock_outline,
            showPasswordToggle: true,
            validator: (value) => Validators.required(value, 'your password'),
          ),
          SizedBox(height: 16.h),
          AppTextField(
            label: 'Confirm Password',
            hint: 'Enter your confirm password',
            controller: _confirmPasswordController,
            icon: Icons.lock_outline,
            showPasswordToggle: true,
            validator: (value) {
              final requiredError =
                  Validators.required(value, 'your confirm password');
              if (requiredError != null) return requiredError;
              return Validators.confirmPassword(
                value,
                _passwordController.text.trim(),
              );
            },
          ),
          SizedBox(height: 30.h),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return AppButton(
                label: 'Create Account',
                isLoading: state is AuthLoading,
                onPressed: () => _onRegister(context),
              );
            },
          ),
          SizedBox(height: 14.h),
          const AuthFormFooter(
            prompt: 'Already have an account?',
            actionLabel: 'Sign in',
            route: AppRouter.login,
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.warning_outlined, color: Colors.orange, size: 18.sp),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'This is dummy function for register, adding a new user will not add it into the server.',
                    style: TextStyle(fontSize: 12.sp, color: colors.secondaryText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
