import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_board_core/quick_board_core.dart';

void main() {
  group('AppColors', () {
    test('background is very dark', () {
      expect(AppColors.background, const Color(0xFF0D0D0D));
    });

    test('gold is warm amber', () {
      expect(AppColors.gold, const Color(0xFFC9973A));
    });

    test('positive score color is green', () {
      expect(AppColors.scorePositive, const Color(0xFF44AA66));
    });

    test('negative score color is red', () {
      expect(AppColors.scoreNegative, const Color(0xFFCC4444));
    });
  });
}
