import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 광고 배너 위젯.
/// - Web: AdSense HTML 배너가 차지하는 공간을 확보하는 spacer
/// - Mobile: [mobileAdBuilder] 콜백으로 AdMob 위젯 주입 (Phase 2)
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
    if (kIsWeb) {
      return const SizedBox(height: height);
    }
    final builder = mobileAdBuilder;
    if (builder != null) {
      return SafeArea(
        top: false,
        left: false,
        right: false,
        child: builder(),
      );
    }
    return const SizedBox.shrink();
  }
}
