import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skulking/models/player_score.dart';
import 'package:skulking/models/skulking_state.dart';
import 'package:skulking/notifiers/skulking_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  SkulkingNotifier notifier() =>
      container.read(skulkingProvider.notifier);

  SkulkingState state() => container.read(skulkingProvider);

  group('startGame', () {
    test('sets players and resets to round 1', () {
      notifier().startGame(['Alice', 'Bob']);
      expect(state().players, ['Alice', 'Bob']);
      expect(state().currentRound, 1);
      expect(state().maxVisitedRound, 1);
      expect(state().scores, isEmpty);
    });
  });

  group('updateScore', () {
    setUp(() => notifier().startGame(['Alice', 'Bob']));

    test('stores score for player+round', () {
      final score = PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: 1);
      notifier().updateScore(0, 1, score);
      expect(state().scores[0]?[1]?.roundScore, 20);
    });

    test('overwriting a score updates it', () {
      notifier().updateScore(0, 1, PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: 1));
      notifier().updateScore(0, 1, PlayerScore(predictedWins: 0, actualWins: 0, bonus: 0, round: 1));
      expect(state().scores[0]?[1]?.roundScore, 10);
    });
  });

  group('advanceRound', () {
    setUp(() {
      notifier().startGame(['Alice', 'Bob']);
      notifier().updateScore(0, 1, PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: 1));
      notifier().updateScore(1, 1, PlayerScore(predictedWins: 0, actualWins: 0, bonus: 0, round: 1));
    });

    test('advances when sum equals round (1+0=1)', () {
      notifier().advanceRound();
      expect(state().currentRound, 2);
      expect(state().maxVisitedRound, 2);
    });

    test('does not advance when sum != round', () {
      notifier().updateScore(1, 1, PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: 1));
      // now both got 1 trick = sum 2 != round 1
      notifier().advanceRound();
      expect(state().currentRound, 1);
    });

    test('does not advance past round 10', () {
      for (var r = 1; r <= 10; r++) {
        // 라운드 r에서는 획득승 합계가 r이어야 다음 라운드로 넘어간다.
        // 매 라운드 합계를 1로 두면 라운드 2에서 멈춘다.
        notifier().updateScore(0, r, PlayerScore(predictedWins: 1, actualWins: r, bonus: 0, round: r));
        notifier().updateScore(1, r, PlayerScore(predictedWins: 0, actualWins: 0, bonus: 0, round: r));
        notifier().advanceRound();
      }
      expect(state().maxVisitedRound, kMaxRounds);
      expect(state().currentRound, kMaxRounds);
    });
  });

  group('goToRound', () {
    setUp(() {
      notifier().startGame(['Alice', 'Bob']);
      notifier().updateScore(0, 1, PlayerScore(predictedWins: 1, actualWins: 1, bonus: 0, round: 1));
      notifier().updateScore(1, 1, PlayerScore(predictedWins: 0, actualWins: 0, bonus: 0, round: 1));
      notifier().advanceRound(); // now on round 2, maxVisited=2
    });

    test('goes back to a visited round', () {
      notifier().goToRound(1);
      expect(state().currentRound, 1);
    });

    test('cannot go to unvisited round', () {
      notifier().goToRound(5);
      expect(state().currentRound, 2); // unchanged
    });
  });
}
