import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';

/// A row of single-digit boxes with auto-advance, backspace handling, paste
/// support, and auto-submit when the last digit is entered.
class OtpInput extends StatefulWidget {
  const OtpInput({
    required this.onChanged,
    required this.onCompleted,
    this.length = AppConstants.otpLength,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;
  final int length;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _handleChanged(int index, String value) {
    // Paste of the full code into one box.
    if (value.length > 1) {
      _distribute(value);
      return;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _emit();
  }

  void _distribute(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    final lastFilled = digits.length.clamp(0, widget.length) - 1;
    if (lastFilled >= 0 && lastFilled < widget.length) {
      _focusNodes[lastFilled].requestFocus();
    }
    _emit();
  }

  void _emit() {
    final value = _value;
    widget.onChanged(value);
    if (value.length == widget.length && !value.contains(' ')) {
      widget.onCompleted(value);
    }
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      _emit();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 48,
          child: Focus(
            onKeyEvent: (_, event) => _onKey(index, event),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: index == 0 ? widget.length : 1,
              style: Theme.of(context).textTheme.headlineSmall,
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => _handleChanged(index, value),
            ),
          ),
        );
      }),
    );
  }
}
