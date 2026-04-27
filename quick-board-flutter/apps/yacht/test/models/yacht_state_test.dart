import 'package:flutter_test/flutter_test.dart';
import 'package:yacht/models/yacht_category.dart';
import 'package:yacht/models/yacht_state.dart';

void main() {
  group('YachtState', () {
    late YachtState emptyState;
    const players = ['Alice', 'Bob'];

    setUp(() {
      emptyState = YachtState(players: players, scores: {});
    });

    group('upperSubtotal', () {
      test('returns 0 when no scores entered', () {
        expect(emptyState.upperSubtotal(0), equals(0));
      });

      test('sums only upper section categories', () {
        final state = YachtState(
          players: players,
          scores: {
            0: {
              YachtCategory.aces: 3,
              YachtCategory.duals: 8,
              YachtCategory.triples: 12,
              YachtCategory.choice: 25, // lower - should NOT be included
            },
          },
        );
        expect(state.upperSubtotal(0), equals(23)); // 3+8+12
      });
    });

    group('bonus', () {
      test('returns 0 when upper subtotal < 63', () {
        final state = YachtState(
          players: players,
          scores: {
            0: {
              YachtCategory.aces: 5,
              YachtCategory.duals: 10,
            },
          },
        );
        expect(state.bonus(0), equals(0));
      });

      test('returns 35 when upper subtotal == 63', () {
        final state = YachtState(
          players: players,
          scores: {
            0: {
              YachtCategory.aces: 3,
              YachtCategory.duals: 10,
              YachtCategory.triples: 15,
              YachtCategory.quads: 20,
              YachtCategory.penta: 15,
            },
          },
        );
        // 3+10+15+20+15 = 63
        expect(state.bonus(0), equals(35));
      });

      test('returns 35 when upper subtotal > 63', () {
        final state = YachtState(
          players: players,
          scores: {
            0: {
              YachtCategory.aces: 5,
              YachtCategory.duals: 10,
              YachtCategory.triples: 15,
              YachtCategory.quads: 20,
              YachtCategory.penta: 25,
              YachtCategory.hexa: 30,
            },
          },
        );
        expect(state.bonus(0), equals(35));
      });
    });

    group('lowerTotal', () {
      test('returns 0 when no lower scores', () {
        expect(emptyState.lowerTotal(0), equals(0));
      });

      test('sums only lower section categories', () {
        final state = YachtState(
          players: players,
          scores: {
            0: {
              YachtCategory.aces: 5, // upper - should NOT be included
              YachtCategory.choice: 25,
              YachtCategory.poker: 20,
              YachtCategory.fullHouse: 18,
              YachtCategory.smallStraight: 30,
              YachtCategory.largeStraight: 0,
              YachtCategory.yacht: 50,
            },
          },
        );
        expect(state.lowerTotal(0), equals(143)); // 25+20+18+30+0+50
      });
    });

    group('totalScore', () {
      test('returns 0 for empty state', () {
        expect(emptyState.totalScore(0), equals(0));
      });

      test('combines upper + bonus + lower correctly', () {
        // Upper subtotal = 63 → bonus = 35
        // Lower = choice(25) + yacht(50) = 75
        // Total = 63 + 35 + 75 = 173
        final state = YachtState(
          players: players,
          scores: {
            0: {
              YachtCategory.aces: 3,
              YachtCategory.duals: 10,
              YachtCategory.triples: 15,
              YachtCategory.quads: 20,
              YachtCategory.penta: 15,
              YachtCategory.hexa: 0,
              YachtCategory.choice: 25,
              YachtCategory.yacht: 50,
            },
          },
        );
        expect(state.totalScore(0), equals(173));
      });
    });

    group('isGameComplete', () {
      test('returns false when no scores entered', () {
        expect(emptyState.isGameComplete, isFalse);
      });

      test('returns true when all players have all 12 categories filled', () {
        final allCategories = {
          for (final cat in YachtCategory.values) cat: 0,
        };
        final state = YachtState(
          players: players,
          scores: {
            0: Map.from(allCategories),
            1: Map.from(allCategories),
          },
        );
        expect(state.isGameComplete, isTrue);
      });

      test('returns false when one player is missing a category', () {
        final allCategories = {
          for (final cat in YachtCategory.values) cat: 0,
        };
        final partialPlayer1 = Map<YachtCategory, int>.from(allCategories)
          ..remove(YachtCategory.yacht);
        final state = YachtState(
          players: players,
          scores: {
            0: Map.from(allCategories),
            1: partialPlayer1,
          },
        );
        expect(state.isGameComplete, isFalse);
      });
    });
  });
}
