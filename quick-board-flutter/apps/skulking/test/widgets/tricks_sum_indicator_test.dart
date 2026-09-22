import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skulking/l10n/app_localizations.dart';
import 'package:skulking/widgets/tricks_sum_indicator.dart';

// TricksSumIndicator는 AppLocalizations.of(context)!를 쓴다.
// 델리게이트를 넣지 않으면 널 오류가 난다. 문구가 흔들리지 않도록 ko로 고정한다.
Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
