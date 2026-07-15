import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Google + (iOS-only) Apple sign-in buttons.
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({
    required this.onGoogle,
    required this.onApple,
    this.enabled = true,
    super.key,
  });

  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final bool enabled;

  bool get _showApple => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata,
          onPressed: enabled ? onGoogle : null,
        ),
        if (_showApple) ...[
          const SizedBox(height: 12),
          _SocialButton(
            label: 'Continue with Apple',
            icon: Icons.apple,
            onPressed: enabled ? onApple : null,
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
