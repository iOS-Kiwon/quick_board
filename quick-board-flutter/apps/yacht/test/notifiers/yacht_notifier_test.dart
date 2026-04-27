import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yacht/models/yacht_category.dart';
import 'package:yacht/models/yacht_state.dart';
import 'package:yacht/notifiers/yacht_notifier.dart';

void main() {
  group('YachtNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('startGame', () {
      test('sets players and clears scores', () {
        container.read(yachtProvider.notifier).startGame(['Alice', 'Bob', 'Carol']);
        final state = container.read(yachtProvider);
        expect(state.players, equals(['Alice', 'Bob', 'Carol']));
        expect(state.scores, isEmpty);
      });
    });

    group('enterScore', () {
      setUp(() {
        container.read(yachtProvider.notifier).startGame(['Alice', 'Bob']);
      });

      test('records a valid score', () {
        container.read(yachtProvider.notifier).enterScore(0, YachtCategory.aces, 3);
        final state = container.read(yachtProvider);
        expect(state.scores[0]?[YachtCategory.aces], equals(3));
      });

      test('caps score at maxScore if input exceeds it', () {
        // aces maxScore = 5; entering 10 should be capped to 5
        container.read(yachtProvider.notifier).enterScore(0, YachtCategory.aces, 10);
        final state = container.read(yachtProvider);
        expect(state.scores[0]?[YachtCategory.aces], equals(5));
      });

      test('caps yacht score to 50 when entering 99', () {
        container.read(yachtProvider.notifier).enterScore(0, YachtCategory.yacht, 99);
        final state = container.read(yachtProvider);
        expect(state.scores[0]?[YachtCategory.yacht], equals(50));
      });

      test('allows entering 0 for any category', () {
        container.read(yachtProvider.notifier).enterScore(0, YachtCategory.yacht, 0);
        final state = container.read(yachtProvider);
        expect(state.scores[0]?[YachtCategory.yacht], equals(0));
      });

      test('allows entering exact maxScore', () {
        container.read(yachtProvider.notifier).enterScore(0, YachtCategory.poker, 24);
        final state = container.read(yachtProvider);
        expect(state.scores[0]?[YachtCategory.poker], equals(24));
      });
    });

    group('clearScore', () {
      setUp(() {
        container.read(yachtProvider.notifier).startGame(['Alice']);
        container.read(yachtProvider.notifier).enterScore(0, YachtCategory.aces, 3);
      });

      test('removes the score entry for a category', () {
        container.read(yachtProvider.notifier).clearScore(0, YachtCategory.aces);
        final state = container.read(yachtProvider);
        expect(state.scores[0]?.containsKey(YachtCategory.aces), isFalse);
      });
    });

    group('resetGame', () {
      test('clears players and scores', () {
        container.read(yachtProvider.notifier).startGame(['Alice', 'Bob']);
        container.read(yachtProvider.notifier).enterScore(0, YachtCategory.aces, 3);
        container.read(yachtProvider.notifier).resetGame();
        final state = container.read(yachtProvider);
        expect(state.players, isEmpty);
        expect(state.scores, isEmpty);
      });
    });
  });
}
