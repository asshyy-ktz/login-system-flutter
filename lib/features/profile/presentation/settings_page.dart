import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/storage/local_storage.dart';
import '../../../di/service_locator.dart';
import '../../auth/data/datasources/biometric_datasource.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final LocalStorage _local = sl<LocalStorage>();
  late bool _biometricEnabled = _local.biometricEnabled;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await sl<BiometricDataSource>().isAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value && _biometricAvailable) {
      final ok = await sl<BiometricDataSource>().authenticate(
        reason: 'Confirm to enable biometric login',
      );
      if (!ok) return;
    }
    await _local.setBiometricEnabled(value);
    if (mounted) setState(() => _biometricEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Biometric login'),
            subtitle: Text(
              _biometricAvailable
                  ? 'Use fingerprint or Face ID to unlock'
                  : 'Not available on this device',
            ),
            value: _biometricEnabled && _biometricAvailable,
            onChanged: _biometricAvailable ? _toggleBiometric : null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () => context.push(AppRoutes.profile),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
