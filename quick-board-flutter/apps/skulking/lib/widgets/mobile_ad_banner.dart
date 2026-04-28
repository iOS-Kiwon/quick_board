import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 배너 위젯 (iOS/Android 전용)
/// main.dart에서 AdBannerWidget.mobileAdBuilder = () => const MobileAdBanner(); 로 등록
class MobileAdBanner extends StatefulWidget {
  const MobileAdBanner({super.key});

  @override
  State<MobileAdBanner> createState() => _MobileAdBannerState();
}

class _MobileAdBannerState extends State<MobileAdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  static String get _adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5980133283002959/9454692536';
    }
    return 'ca-app-pub-5980133283002959/1616339778';
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (ad == null || !_isLoaded) {
      return const SizedBox(height: 60);
    }
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
