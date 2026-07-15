import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../di/service_locator.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/login_cubit.dart';
import '../formz/auth_inputs.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_buttons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => sl<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
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
            final cubit = context.read<LoginCubit>();
            final isLoading = state.status.isInProgress;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
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
                        textInputAction: TextInputAction.done,
                        errorText: _passwordError(state.password),
                        onChanged: cubit.passwordChanged,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: state.rememberMe,
                                onChanged: (v) =>
                                    cubit.rememberMeChanged(v ?? false),
                              ),
                              const Text('Remember me'),
                            ],
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.forgotPassword),
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LoadingButton(
                        label: 'Log in',
                        isLoading: isLoading,
                        onPressed: cubit.submit,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.otp),
                        child: const Text('Sign in with phone number'),
                      ),
                      const SizedBox(height: 8),
                      const _OrDivider(),
                      const SizedBox(height: 16),
                      SocialLoginButtons(
                        enabled: !isLoading,
                        onGoogle: cubit.loginWithGoogle,
                        onApple: cubit.loginWithApple,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.register),
                            child: const Text('Sign up'),
                          ),
                        ],
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR', style: Theme.of(context).textTheme.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
