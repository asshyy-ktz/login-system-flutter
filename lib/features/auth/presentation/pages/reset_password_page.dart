import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../di/service_locator.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../bloc/password_cubit.dart';
import '../formz/auth_inputs.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_strength_indicator.dart';

/// Reached from the reset-password deep link, which supplies the [token].
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({required this.token, super.key});

  final String token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PasswordCubit>(
      create: (_) => sl<PasswordCubit>(),
      child: _ResetPasswordView(token: token),
    );
  }
}

class _ResetPasswordView extends StatelessWidget {
  const _ResetPasswordView({required this.token});

  final String token;

  String? _passwordError(Password password) {
    if (password.isPure || password.isValid) return null;
    return switch (password.error) {
      PasswordError.empty => 'Password is required',
      PasswordError.tooShort => 'At least 8 characters',
      null => null,
    };
  }

  String? _confirmError(ConfirmedPassword confirmed) {
    if (confirmed.isPure || confirmed.isValid) return null;
    return switch (confirmed.error) {
      ConfirmedPasswordError.empty => 'Confirm your password',
      ConfirmedPasswordError.mismatch => 'Passwords do not match',
      null => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: BlocConsumer<PasswordCubit, PasswordState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated. Please log in.')),
              );
              context.go(AppRoutes.login);
            } else if (state.status.isFailure && state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            final cubit = context.read<PasswordCubit>();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'New password',
                    prefixIcon: Icons.lock_outline,
                    obscure: true,
                    errorText: _passwordError(state.password),
                    onChanged: cubit.passwordChanged,
                  ),
                  PasswordStrengthIndicator(password: state.password),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirm password',
                    prefixIcon: Icons.lock_outline,
                    obscure: true,
                    errorText: _confirmError(state.confirmedPassword),
                    onChanged: cubit.confirmedPasswordChanged,
                  ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    label: 'Update password',
                    isLoading: state.status.isInProgress,
                    onPressed: () => cubit.resetPassword(token),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
