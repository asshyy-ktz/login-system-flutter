import 'package:flutter/material.dart';

/// Wraps [child] and shows a dimmed full-screen spinner when [isLoading].
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const ModalBarrier(dismissible: false, color: Colors.black54),
        if (isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
