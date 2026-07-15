import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_system_flutter/features/auth/presentation/widgets/otp_input.dart';

void main() {
  testWidgets('auto-submits when all digits are entered', (tester) async {
    String? completed;
    var lastValue = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpInput(
            onChanged: (v) => lastValue = v,
            onCompleted: (v) => completed = v,
          ),
        ),
      ),
    );

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(6));

    for (var i = 0; i < 6; i++) {
      await tester.enterText(fields.at(i), '${i + 1}');
      await tester.pump();
    }

    expect(lastValue, '123456');
    expect(completed, '123456');
  });

  testWidgets('distributes a pasted code across all boxes', (tester) async {
    String? completed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpInput(
            onChanged: (_) {},
            onCompleted: (v) => completed = v,
          ),
        ),
      ),
    );

    // Paste into the first box (maxLength allows the full code there).
    await tester.enterText(find.byType(TextField).first, '987654');
    await tester.pump();

    expect(completed, '987654');
  });
}
