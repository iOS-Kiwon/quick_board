import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

Future<void> requestTrackingPermission() async {
  if (kIsWeb || !Platform.isIOS) return;
  // iOS는 앱이 active 상태가 된 직후에만 다이얼로그를 띄울 수 있으므로 짧게 대기
  await Future.delayed(const Duration(milliseconds: 500));
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  debugPrint('[ATT] current status before request: $status');
  if (status == TrackingStatus.notDetermined) {
    final result = await AppTrackingTransparency.requestTrackingAuthorization();
    debugPrint('[ATT] requestTrackingAuthorization result: $result');
  } else {
    debugPrint('[ATT] already decided, skip prompt');
  }
}

Future<bool> isTrackingAuthorized() async {
  if (kIsWeb) return false;
  if (!Platform.isIOS) return true;
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  return status == TrackingStatus.authorized;
}
