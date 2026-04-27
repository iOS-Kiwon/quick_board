import 'package:flutter_test/flutter_test.dart';
import 'package:yacht/models/yacht_category.dart';

void main() {
  group('YachtCategory', () {
    group('isUpper', () {
      test('aces through hexa are upper section', () {
        expect(YachtCategory.aces.isUpper, isTrue);
        expect(YachtCategory.duals.isUpper, isTrue);
        expect(YachtCategory.triples.isUpper, isTrue);
        expect(YachtCategory.quads.isUpper, isTrue);
        expect(YachtCategory.penta.isUpper, isTrue);
        expect(YachtCategory.hexa.isUpper, isTrue);
      });

      test('lower categories are not upper section', () {
        expect(YachtCategory.choice.isUpper, isFalse);
        expect(YachtCategory.poker.isUpper, isFalse);
        expect(YachtCategory.fullHouse.isUpper, isFalse);
        expect(YachtCategory.smallStraight.isUpper, isFalse);
        expect(YachtCategory.largeStraight.isUpper, isFalse);
        expect(YachtCategory.yacht.isUpper, isFalse);
      });
    });

    group('maxScore', () {
      test('upper section maxScores are correct', () {
        expect(YachtCategory.aces.maxScore, equals(5));
        expect(YachtCategory.duals.maxScore, equals(10));
        expect(YachtCategory.triples.maxScore, equals(15));
        expect(YachtCategory.quads.maxScore, equals(20));
        expect(YachtCategory.penta.maxScore, equals(25));
        expect(YachtCategory.hexa.maxScore, equals(30));
      });

      test('lower section maxScores are correct', () {
        expect(YachtCategory.choice.maxScore, equals(30));
        expect(YachtCategory.poker.maxScore, equals(24));
        expect(YachtCategory.fullHouse.maxScore, equals(28));
        expect(YachtCategory.smallStraight.maxScore, equals(30));
        expect(YachtCategory.largeStraight.maxScore, equals(30));
        expect(YachtCategory.yacht.maxScore, equals(50));
      });
    });

    group('fixedScore', () {
      test('smallStraight, largeStraight, yacht have fixed scores', () {
        expect(YachtCategory.smallStraight.fixedScore, equals(30));
        expect(YachtCategory.largeStraight.fixedScore, equals(30));
        expect(YachtCategory.yacht.fixedScore, equals(50));
      });

      test('other categories have null fixedScore', () {
        expect(YachtCategory.aces.fixedScore, isNull);
        expect(YachtCategory.choice.fixedScore, isNull);
        expect(YachtCategory.poker.fixedScore, isNull);
        expect(YachtCategory.fullHouse.fixedScore, isNull);
      });
    });
  });
}
