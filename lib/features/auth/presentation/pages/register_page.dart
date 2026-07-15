import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../di/service_locator.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/register_cubit.dart';
import '../formz/auth_inputs.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_strength_indicator.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (_) => sl<RegisterCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  String? _emailError(Email email) {
    if (email.isPure || email.isValid) return null;
    return switch (email.error) {
      EmailError.empty => 'Email is required',
      EmailError.invalid => 'Enter a valid email',
      null => null,
    };
  }

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
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status.isSuccess && state.user != null) {
              context.read<AuthBloc>().add(AuthUserChanged(state.user!));
              context.go(AppRoutes.home);
            } else if (state.status.isFailure && state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            final cubit = context.read<RegisterCubit>();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        label: 'Name (optional)',
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        onChanged: cubit.nameChanged,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        errorText: _emailError(state.email),
                        onChanged: cubit.emailChanged,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                        errorText: _passwordError(state.password),
                        onChanged: cubit.passwordChanged,
                      ),
                      PasswordStrengthIndicator(password: state.password),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Confirm password',
                        prefixIcon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        errorText: _confirmError(state.confirmedPassword),
                        onChanged: cubit.confirmedPasswordChanged,
                      ),
                      const SizedBox(height: 24),
                      LoadingButton(
                        label: 'Create account',
                        isLoading: state.status.isInProgress,
                        onPressed: cubit.submit,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
