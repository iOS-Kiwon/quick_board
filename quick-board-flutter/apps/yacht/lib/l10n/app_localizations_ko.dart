// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '요트다이스 점수계산';

  @override
  String get setupTitle => '게임 설정';

  @override
  String get playerCount => '플레이어 수';

  @override
  String playerName(int n) {
    return '플레이어 $n 이름';
  }

  @override
  String get startGame => '🎲 게임 시작';

  @override
  String get endGame => '🏁 게임 종료';

  @override
  String progressLabel(int filled, int total) {
    return '$filled/$total 카테고리 입력됨';
  }

  @override
  String get headerCategory => '카테고리';

  @override
  String get upperSubtotal => '소계';

  @override
  String get bonusLabel => '보너스 (+35)';

  @override
  String get totalScore => '총점';

  @override
  String get catAces => '에이스';

  @override
  String get catDuals => '듀얼';

  @override
  String get catTriples => '트리플';

  @override
  String get catQuads => '쿼드';

  @override
  String get catPenta => '펜타';

  @override
  String get catHexa => '헥사';

  @override
  String get catChoice => '초이스';

  @override
  String get catPoker => '포커';

  @override
  String get catFullHouse => '풀하우스';

  @override
  String get catSmallStraight => '스몰 스트레이트';

  @override
  String get catLargeStraight => '라지 스트레이트';

  @override
  String get catYacht => '요트';

  @override
  String maxScoreHint(int max) {
    return '최대 $max점';
  }

  @override
  String autoConverted(int max) {
    return '$max점으로 자동 변환됩니다';
  }

  @override
  String get confirmButton => '확인';

  @override
  String get cancelButton => '취소';

  @override
  String get scoreInputHint => '점수 입력';

  @override
  String get finalResult => '🏆 최종 결과';

  @override
  String get shareResult => '📋 결과 공유';

  @override
  String get playAgain => '🔄 다시 하기';

  @override
  String rankLabel(int rank) {
    return '$rank위';
  }

  @override
  String pointsSuffix(String score) {
    return '$score점';
  }

  @override
  String get shareHeader => '🎲 요트 다이스 게임 결과 🎲';

  @override
  String get shareFinalStandings => '[ 최종 순위 ]';

  @override
  String get shareRoundScores => '[ 카테고리별 점수 ]';

  @override
  String get shareUpperSubtotal => '상단 소계';

  @override
  String get shareBonus => '보너스';

  @override
  String get shareTotal => '합계';
}
