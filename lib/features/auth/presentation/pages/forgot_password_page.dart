import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../di/service_locator.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../bloc/password_cubit.dart';
import '../formz/auth_inputs.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PasswordCubit>(
      create: (_) => sl<PasswordCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SafeArea(
        child: BlocBuilder<PasswordCubit, PasswordState>(
          builder: (context, state) {
            final cubit = context.read<PasswordCubit>();
            if (state.status.isSuccess) {
              return const _CheckEmailView();
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "Enter your email and we'll send you a reset link.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    errorText: (state.email.isPure || state.email.isValid)
                        ? null
                        : 'Enter a valid email',
                    onChanged: cubit.emailChanged,
                  ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    label: 'Send reset link',
                    isLoading: state.status.isInProgress,
                    onPressed: cubit.sendResetEmail,
                  ),
                  if (state.status.isFailure && state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
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

class _CheckEmailView extends StatelessWidget {
  const _CheckEmailView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 96),
            const SizedBox(height: 24),
            Text(
              'Check your email',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'We sent a password reset link to your inbox. '
              'Follow it to choose a new password.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
