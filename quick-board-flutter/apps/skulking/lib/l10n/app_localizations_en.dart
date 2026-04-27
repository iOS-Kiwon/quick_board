// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Skull King Score';

  @override
  String get setupTitle => 'Game Setup';

  @override
  String get playerCount => 'Number of Players';

  @override
  String playerName(int n) {
    return 'Player $n Name';
  }

  @override
  String get startGame => '⚓ Start Game';

  @override
  String get predictedWins => 'Bid';

  @override
  String get actualWins => 'Tricks';

  @override
  String get bonus => 'Bonus';

  @override
  String get roundScore => 'Score';

  @override
  String get nextRound => 'Next Round ▶';

  @override
  String get endGame => '🏁 End Game';

  @override
  String tricksTotal(int sum, int round) {
    return 'Tricks total: $sum / $round';
  }

  @override
  String get tricksMismatch => 'Total must equal the round number';

  @override
  String get tricksOk => '✓';

  @override
  String get finalResult => '🏆 Final Results';

  @override
  String get shareResult => '📋 Share Results';

  @override
  String get playAgain => '🔄 Play Again';

  @override
  String get shareHeader => '☠️ Skull King Results ☠️';

  @override
  String get shareFinalStandings => '[ Final Standings ]';

  @override
  String get shareRoundScores => '[ Round Scores ]';

  @override
  String get shareTotal => 'Total';

  @override
  String roundLabel(int round) {
    return '$round / 10';
  }

  @override
  String get cumulativeScore => '📊 Cumulative Score';

  @override
  String roundPrefix(int round) {
    return 'R$round';
  }

  @override
  String rankLabel(int rank) {
    return '${rank}th';
  }

  @override
  String pointsSuffix(String score) {
    return '${score}pts';
  }
}
