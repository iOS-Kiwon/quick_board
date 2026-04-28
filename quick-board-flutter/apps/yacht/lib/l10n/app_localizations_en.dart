// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Yacht Dice Score';

  @override
  String get setupTitle => 'Game Setup';

  @override
  String get playerCount => 'Players';

  @override
  String playerName(int n) {
    return 'Player $n name';
  }

  @override
  String get startGame => '🎲 Start Game';

  @override
  String get endGame => '🏁 End Game';

  @override
  String progressLabel(int filled, int total) {
    return '$filled/$total categories filled';
  }

  @override
  String get headerCategory => 'Category';

  @override
  String get upperSubtotal => 'Subtotal';

  @override
  String get bonusLabel => 'Bonus (+35)';

  @override
  String get totalScore => 'Total';

  @override
  String get catAces => 'Aces';

  @override
  String get catDuals => 'Duals';

  @override
  String get catTriples => 'Triples';

  @override
  String get catQuads => 'Quads';

  @override
  String get catPenta => 'Penta';

  @override
  String get catHexa => 'Hexa';

  @override
  String get catChoice => 'Choice';

  @override
  String get catPoker => 'Poker';

  @override
  String get catFullHouse => 'Full House';

  @override
  String get catSmallStraight => 'Small Straight';

  @override
  String get catLargeStraight => 'Large Straight';

  @override
  String get catYacht => 'Yacht';

  @override
  String maxScoreHint(int max) {
    return 'Max $max pts';
  }

  @override
  String autoConverted(int max) {
    return 'Will be auto-converted to $max pts';
  }

  @override
  String get confirmButton => 'Confirm';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get scoreInputHint => 'Enter score';

  @override
  String get finalResult => '🏆 Final Results';

  @override
  String get shareResult => '📋 Share Results';

  @override
  String get playAgain => '🔄 Play Again';

  @override
  String rankLabel(int rank) {
    return '#$rank';
  }

  @override
  String pointsSuffix(String score) {
    return '$score pts';
  }

  @override
  String get shareHeader => '🎲 Yacht Dice Results 🎲';

  @override
  String get shareFinalStandings => '[ Final Standings ]';

  @override
  String get shareRoundScores => '[ Category Scores ]';

  @override
  String get shareUpperSubtotal => 'Upper Subtotal';

  @override
  String get shareBonus => 'Bonus';

  @override
  String get shareTotal => 'Total';
}
