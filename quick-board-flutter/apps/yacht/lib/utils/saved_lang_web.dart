// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String? readSavedLang() {
  try {
    final stored = html.window.localStorage['quickboard.lang'];
    if (stored == 'ko' || stored == 'en') return stored;
  } catch (_) {}
  return null;
}
