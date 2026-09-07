import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quick_board_core/quick_board_core.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'utils/saved_lang.dart';
import 'utils/tracking.dart';
import 'widgets/mobile_ad_banner.dart';

const bool showAdMob = bool.fromEnvironment(
  'SHOW_ADMOB',
  defaultValue: true,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && showAdMob) {
    MobileAds.instance.initialize();
    AdBannerWidget.mobileAdBuilder = () => const MobileAdBanner();
  }

  runApp(const ProviderScope(child: SkulkingApp()));

  // ATT 다이얼로그는 앱이 frontmost 상태가 된 뒤에만 표시되므로 첫 프레임 이후에 요청한다.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (showAdMob) {
      requestTrackingPermission();
    }
  });
}

class SkulkingApp extends StatelessWidget {
  const SkulkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final savedLang = readSavedLang();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.dark,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      locale: savedLang != null ? Locale(savedLang) : null,
      // 배너는 Navigator보다 위에 하나만 둔다. 화면 전환은 `child`만 교체하므로
      // 배너 State와 로드된 BannerAd가 setup → game → result 이동 내내 살아남는다.
      //
      // 위치는 화면 최상단(세이프에어리어 바로 아래)이다. 모든 화면이 값을
      // 입력하는 화면이라 하단에 두면 키패드에 가려 노출되지 않는다.
      builder: (context, child) {
        final content = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child ?? const SizedBox.shrink(),
        );
        return Column(
          children: [
            // 상단 인셋은 광고 유무와 무관하게 여기서 소비한다.
            const SafeArea(
              bottom: false,
              left: false,
              right: false,
              child: AdBannerWidget(),
            ),
            // 아래 화면들이 상단 인셋을 또 넣지 않도록 제거한다.
            // (AppBar는 SafeArea와 별개로 MediaQuery.padding.top을 직접 읽는다)
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: content,
              ),
            ),
          ],
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
