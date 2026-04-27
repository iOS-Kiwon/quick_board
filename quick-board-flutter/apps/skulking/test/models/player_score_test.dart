import 'package:flutter_test/flutter_test.dart';
import 'package:skulking/models/player_score.dart';

void main() {
  group('calculateRoundScore', () {
    test('0 bid success: round × 10', () {
      final s = PlayerScore(predictedWins: 0, actualWins: 0, bonus: 0, round: 3);
      expect(s.roundScore, 30);
    });

    test('0 bid fail: -(round × 10)', () {
      final s = PlayerScore(predictedWins: 0, actualWins: 2, bonus: 0, round: 3);
      expect(s.roundScore, -30);
    });

    test('non-zero bid success: bid × 20 + bonus', () {
      final s = PlayerScore(predictedWins: 2, actualWins: 2, bonus: 30, round: 3);
      expect(s.roundScore, 70);
    });

    test('non-zero bid fail: -|diff| × 10', () {
      final s = PlayerScore(predictedWins: 3, actualWins: 1, bonus: 0, round: 4);
      expect(s.roundScore, -20);
    });

    test('bonus ignored on fail', () {
      final s = PlayerScore(predictedWins: 3, actualWins: 1, bonus: 50, round: 4);
      expect(s.roundScore, -20);
    });

    test('bonus ignored when bid is 0', () {
      final s = PlayerScore(predictedWins: 0, actualWins: 0, bonus: 20, round: 2);
      expect(s.roundScore, 20);
    });
  });
}
