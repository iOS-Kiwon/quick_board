// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '스컬킹 점수계산';

  @override
  String get setupTitle => '☠️ 게임 설정';

  @override
  String get playerCount => '플레이어 수';

  @override
  String playerCountSuffix(int n) {
    return '$n명';
  }

  @override
  String get playerNamesTitle => '플레이어 이름';

  @override
  String playerName(int n) {
    return '플레이어 $n 이름';
  }

  @override
  String defaultPlayerName(int n) {
    return '플레이어 $n';
  }

  @override
  String get startGame => '⚓ 게임 시작';

  @override
  String get playerHeader => '플레이어';

  @override
  String get roundHeader => '라운드';

  @override
  String get predictedWins => '예측승';

  @override
  String get actualWins => '획득승';

  @override
  String get bonus => '보너스';

  @override
  String get roundScore => '점수';

  @override
  String get nextRound => '다음 라운드 ▶';

  @override
  String get endGame => '🏁 게임 종료';

  @override
  String tricksTotal(int sum, int round) {
    return '획득승 합계: $sum / $round';
  }

  @override
  String get tricksMismatch => '합계가 라운드 수와 맞지 않습니다';

  @override
  String get tricksOk => '✓';

  @override
  String get finalResult => '🏆 최종 결과';

  @override
  String get shareResult => '📋 결과 공유';

  @override
  String get sharingPreparing => '⏳ 공유 준비 중...';

  @override
  String get playAgain => '🔄 다시 하기';

  @override
  String get shareSubject => '스컬킹 게임 결과';

  @override
  String get shareHeader => '☠️ 스컬킹 게임 결과 ☠️';

  @override
  String get shareFinalStandings => '[ 최종 순위 ]';

  @override
  String get shareRoundScores => '[ 라운드별 점수 ]';

  @override
  String get shareTotal => '합계';

  @override
  String roundLabel(int round) {
    return '$round / 10';
  }

  @override
  String get cumulativeScore => '📊 누적 총점';

  @override
  String roundPrefix(int round) {
    return 'R$round';
  }

  @override
  String rankLabel(int rank) {
    return '$rank위';
  }

  @override
  String pointsSuffix(String score) {
    return '$score점';
  }
}
