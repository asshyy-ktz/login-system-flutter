import 'package:flutter/material.dart';

import '../formz/auth_inputs.dart';

/// Renders a coloured bar + label reflecting [PasswordStrength].
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({required this.password, super.key});

  final Password password;

  @override
  Widget build(BuildContext context) {
    if (password.value.isEmpty) return const SizedBox.shrink();

    final strength = password.strength;
    final (label, color, fraction) = switch (strength) {
      PasswordStrength.weak => ('Weak', Colors.red, 0.33),
      PasswordStrength.medium => ('Medium', Colors.orange, 0.66),
      PasswordStrength.strong => ('Strong', Colors.green, 1.0),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Password strength: $label',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}
