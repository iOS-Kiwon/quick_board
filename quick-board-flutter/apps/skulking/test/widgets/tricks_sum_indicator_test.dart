import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skulking/widgets/tricks_sum_indicator.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('shows check mark when sum equals round', (tester) async {
    await tester.pumpWidget(_wrap(
      const TricksSumIndicator(sum: 3, round: 3),
    ));
    expect(find.textContaining('✓'), findsOneWidget);
  });

  testWidgets('shows warning when sum != round', (tester) async {
    await tester.pumpWidget(_wrap(
      const TricksSumIndicator(sum: 2, round: 3),
    ));
    expect(find.textContaining('2 / 3'), findsOneWidget);
  });
}
