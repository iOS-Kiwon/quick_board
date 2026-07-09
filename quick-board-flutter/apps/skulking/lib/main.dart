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
      builder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child,
      ),
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
