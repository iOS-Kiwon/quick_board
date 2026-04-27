import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'요트 다이스'**
  String get appName;

  /// No description provided for @setupTitle.
  ///
  /// In ko, this message translates to:
  /// **'게임 설정'**
  String get setupTitle;

  /// No description provided for @playerCount.
  ///
  /// In ko, this message translates to:
  /// **'플레이어 수'**
  String get playerCount;

  /// No description provided for @playerName.
  ///
  /// In ko, this message translates to:
  /// **'플레이어 {n} 이름'**
  String playerName(int n);

  /// No description provided for @startGame.
  ///
  /// In ko, this message translates to:
  /// **'🎲 게임 시작'**
  String get startGame;

  /// No description provided for @endGame.
  ///
  /// In ko, this message translates to:
  /// **'🏁 게임 종료'**
  String get endGame;

  /// No description provided for @progressLabel.
  ///
  /// In ko, this message translates to:
  /// **'{filled}/{total} 카테고리 입력됨'**
  String progressLabel(int filled, int total);

  /// No description provided for @headerCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리'**
  String get headerCategory;

  /// No description provided for @upperSubtotal.
  ///
  /// In ko, this message translates to:
  /// **'소계'**
  String get upperSubtotal;

  /// No description provided for @bonusLabel.
  ///
  /// In ko, this message translates to:
  /// **'보너스 (+35)'**
  String get bonusLabel;

  /// No description provided for @totalScore.
  ///
  /// In ko, this message translates to:
  /// **'총점'**
  String get totalScore;

  /// No description provided for @catAces.
  ///
  /// In ko, this message translates to:
  /// **'에이스'**
  String get catAces;

  /// No description provided for @catDuals.
  ///
  /// In ko, this message translates to:
  /// **'듀얼'**
  String get catDuals;

  /// No description provided for @catTriples.
  ///
  /// In ko, this message translates to:
  /// **'트리플'**
  String get catTriples;

  /// No description provided for @catQuads.
  ///
  /// In ko, this message translates to:
  /// **'쿼드'**
  String get catQuads;

  /// No description provided for @catPenta.
  ///
  /// In ko, this message translates to:
  /// **'펜타'**
  String get catPenta;

  /// No description provided for @catHexa.
  ///
  /// In ko, this message translates to:
  /// **'헥사'**
  String get catHexa;

  /// No description provided for @catChoice.
  ///
  /// In ko, this message translates to:
  /// **'초이스'**
  String get catChoice;

  /// No description provided for @catPoker.
  ///
  /// In ko, this message translates to:
  /// **'포커'**
  String get catPoker;

  /// No description provided for @catFullHouse.
  ///
  /// In ko, this message translates to:
  /// **'풀하우스'**
  String get catFullHouse;

  /// No description provided for @catSmallStraight.
  ///
  /// In ko, this message translates to:
  /// **'스몰 스트레이트'**
  String get catSmallStraight;

  /// No description provided for @catLargeStraight.
  ///
  /// In ko, this message translates to:
  /// **'라지 스트레이트'**
  String get catLargeStraight;

  /// No description provided for @catYacht.
  ///
  /// In ko, this message translates to:
  /// **'요트'**
  String get catYacht;

  /// No description provided for @maxScoreHint.
  ///
  /// In ko, this message translates to:
  /// **'최대 {max}점'**
  String maxScoreHint(int max);

  /// No description provided for @autoConverted.
  ///
  /// In ko, this message translates to:
  /// **'{max}점으로 자동 변환됩니다'**
  String autoConverted(int max);

  /// No description provided for @confirmButton.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirmButton;

  /// No description provided for @cancelButton.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancelButton;

  /// No description provided for @scoreInputHint.
  ///
  /// In ko, this message translates to:
  /// **'점수 입력'**
  String get scoreInputHint;

  /// No description provided for @finalResult.
  ///
  /// In ko, this message translates to:
  /// **'🏆 최종 결과'**
  String get finalResult;

  /// No description provided for @shareResult.
  ///
  /// In ko, this message translates to:
  /// **'📋 결과 공유'**
  String get shareResult;

  /// No description provided for @playAgain.
  ///
  /// In ko, this message translates to:
  /// **'🔄 다시 하기'**
  String get playAgain;

  /// No description provided for @rankLabel.
  ///
  /// In ko, this message translates to:
  /// **'{rank}위'**
  String rankLabel(int rank);

  /// No description provided for @pointsSuffix.
  ///
  /// In ko, this message translates to:
  /// **'{score}점'**
  String pointsSuffix(String score);

  /// No description provided for @shareHeader.
  ///
  /// In ko, this message translates to:
  /// **'🎲 요트 다이스 게임 결과 🎲'**
  String get shareHeader;

  /// No description provided for @shareFinalStandings.
  ///
  /// In ko, this message translates to:
  /// **'[ 최종 순위 ]'**
  String get shareFinalStandings;

  /// No description provided for @shareRoundScores.
  ///
  /// In ko, this message translates to:
  /// **'[ 카테고리별 점수 ]'**
  String get shareRoundScores;

  /// No description provided for @shareUpperSubtotal.
  ///
  /// In ko, this message translates to:
  /// **'상단 소계'**
  String get shareUpperSubtotal;

  /// No description provided for @shareBonus.
  ///
  /// In ko, this message translates to:
  /// **'보너스'**
  String get shareBonus;

  /// No description provided for @shareTotal.
  ///
  /// In ko, this message translates to:
  /// **'합계'**
  String get shareTotal;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
