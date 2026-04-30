import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quick_board_core/quick_board_core.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'widgets/mobile_ad_banner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    // TODO: 프로덕션 배포 전 실제 AdMob App ID로 Info.plist / AndroidManifest.xml 설정 필요
    MobileAds.instance.initialize();
    AdBannerWidget.mobileAdBuilder = () => const MobileAdBanner();
  }

  runApp(const ProviderScope(child: SkulkingApp()));
}

class SkulkingApp extends StatelessWidget {
  const SkulkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.dark,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
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
