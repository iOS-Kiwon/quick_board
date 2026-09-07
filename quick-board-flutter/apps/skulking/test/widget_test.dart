import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_board_core/quick_board_core.dart';
import 'package:skulking/main.dart';
import 'package:skulking/screens/setup_screen.dart';

void main() {
  testWidgets('앱을 띄우면 설정 화면이 나오고 광고 자리는 그 위에 있다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SkulkingApp()));
    await tester.pumpAndSettle();

    expect(find.byType(SetupScreen), findsOneWidget);

    // 광고 배너는 Navigator보다 위(화면 최상단)에 놓인다.
    // 테스트에서는 mobileAdBuilder가 없어 높이 0이지만 위치는 확인할 수 있다.
    final bannerTop = tester.getTopLeft(find.byType(AdBannerWidget)).dy;
    final screenTop = tester.getTopLeft(find.byType(SetupScreen)).dy;
    expect(bannerTop, lessThanOrEqualTo(screenTop));
  });
}
