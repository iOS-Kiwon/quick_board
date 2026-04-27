import 'package:flutter/material.dart';
import 'package:quick_board_core/quick_board_core.dart';

class TricksSumIndicator extends StatelessWidget {
  const TricksSumIndicator({
    super.key,
    required this.sum,
    required this.round,
  });

  final int sum;
  final int round;

  @override
  Widget build(BuildContext context) {
    final ok = sum == round;
    final color = ok ? AppColors.scorePositive : AppColors.scoreNegative;
    final label = ok
        ? '획득승 합계: $sum / $round ✓'
        : '획득승 합계: $sum / $round — 합계가 라운드 수와 맞지 않습니다';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: AppTextStyles.body.copyWith(color: color)),
    );
  }
}
