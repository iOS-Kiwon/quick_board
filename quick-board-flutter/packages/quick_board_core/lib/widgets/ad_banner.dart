import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 광고 배너 위젯.
/// - Web: AdSense HTML 배너가 차지하는 공간을 확보하는 spacer
/// - Mobile: [mobileAdBuilder] 콜백으로 AdMob 위젯 주입 (Phase 2)
///
/// 세이프에어리어(노치·상태바) 여백은 이 위젯을 배치하는 쪽(각 앱 main.dart)이
/// 처리한다. 광고를 끈 빌드에서도 화면 여백이 똑같이 유지되어야 하기 때문이다.
class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  /// Phase 2: 각 앱 main.dart에서 AdMob BannerAd 위젯을 반환하는 빌더를 등록
  /// ```dart
  /// AdBannerWidget.mobileAdBuilder = () => MobileAdBanner();
  /// ```
  static Widget Function()? mobileAdBuilder;

  /// AdSense/AdMob 배너 높이 (px)
  static const double height = 60.0;

  @override
  Widget build(BuildContext context) {
    final Widget banner;
    if (kIsWeb) {
      banner = const SizedBox(height: height);
    } else {
      final builder = mobileAdBuilder;
      if (builder == null) return const SizedBox.shrink();
      banner = builder();
    }
    // 광고와 앱 조작 요소 사이에 눌리지 않는 여백과 경계선을 둔다.
    // AdMob은 오클릭을 막기 위해 이런 분리를 요구한다.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        banner,
        const SizedBox(height: 4),
        Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }
}
