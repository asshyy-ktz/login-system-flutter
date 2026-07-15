import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes.dart';
import '../../../di/service_locator.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/widgets/custom_text_field.dart';
import 'profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => sl<ProfileBloc>()..add(const ProfileLoaded()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (p, c) => p.status != c.status || p.message != c.message,
        listener: (context, state) {
          if (state.status == ProfileStatus.deleted) {
            context.read<AuthBloc>().add(const AuthLogoutRequested());
            context.go(AppRoutes.login);
          } else if (state.message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading && state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state.user;
          final nameController = TextEditingController(text: user?.name ?? '');
          final phoneController = TextEditingController(text: user?.phone ?? '');
          final saving = state.status == ProfileStatus.saving;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          onPressed: () => _showAvatarSheet(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Name',
                  prefixIcon: Icons.person_outline,
                  controller: nameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  controller: TextEditingController(text: user?.email ?? ''),
                  enabled: false,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone',
                  prefixIcon: Icons.phone_outlined,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () => context.read<ProfileBloc>().add(
                            ProfileUpdated(
                              name: nameController.text,
                              phone: phoneController.text,
                            ),
                          ),
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save changes'),
                ),
                const Divider(height: 48),
                OutlinedButton.icon(
                  icon: const Icon(Icons.password),
                  label: const Text('Change password'),
                  onPressed: () => _showChangePassword(context),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete account'),
                  onPressed: () => _showDeleteAccount(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAvatarSheet(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickAvatarWithBloc(bloc, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickAvatarWithBloc(bloc, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatarWithBloc(
    ProfileBloc bloc,
    ImageSource source,
  ) async {
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      bloc.add(ProfileAvatarChanged(picked.path));
    }
  }

  void _showChangePassword(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    final current = TextEditingController();
    final next = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'Current password',
              obscure: true,
              controller: current,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'New password',
              obscure: true,
              controller: next,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              bloc.add(ProfilePasswordChanged(
                currentPassword: current.text,
                newPassword: next.text,
              ));
              Navigator.pop(dialogContext);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    final password = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This permanently deletes your account. '
              'Enter your password to confirm.',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              obscure: true,
              controller: password,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              bloc.add(ProfileDeleted(password.text));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
