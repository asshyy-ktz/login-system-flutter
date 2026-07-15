import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../di/service_locator.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/otp_cubit.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/otp_input.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OtpCubit>(
      create: (_) => sl<OtpCubit>(),
      child: const _OtpView(),
    );
  }
}

class _OtpView extends StatelessWidget {
  const _OtpView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone verification')),
      body: SafeArea(
        child: BlocConsumer<OtpCubit, OtpState>(
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
            final cubit = context.read<OtpCubit>();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: state.step == OtpStep.enterPhone
                  ? _PhoneStep(cubit: cubit, state: state)
                  : _CodeStep(cubit: cubit, state: state),
            );
          },
        ),
      ),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({required this.cubit, required this.state});
  final OtpCubit cubit;
  final OtpState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          'Enter your phone number',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('Include your country code, e.g. +1 555 123 4567.'),
        const SizedBox(height: 24),
        CustomTextField(
          label: 'Phone number',
          hint: '+1 555 123 4567',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          onChanged: cubit.phoneChanged,
        ),
        const SizedBox(height: 24),
        LoadingButton(
          label: 'Send code',
          isLoading: state.status.isInProgress,
          onPressed: cubit.sendCode,
        ),
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({required this.cubit, required this.state});
  final OtpCubit cubit;
  final OtpState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          'Enter the code',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text('We sent a 6-digit code to ${state.phone}.'),
        const SizedBox(height: 24),
        OtpInput(
          onChanged: cubit.codeChanged,
          onCompleted: (_) => cubit.verify(),
        ),
        const SizedBox(height: 24),
        LoadingButton(
          label: 'Verify',
          isLoading: state.status.isInProgress,
          onPressed: cubit.verify,
        ),
        const SizedBox(height: 16),
        Center(
          child: state.canResend
              ? TextButton(
                  onPressed: cubit.resend,
                  child: const Text('Resend code'),
                )
              : Text('Resend code in ${state.secondsRemaining}s'),
        ),
      ],
    );
  }
}
