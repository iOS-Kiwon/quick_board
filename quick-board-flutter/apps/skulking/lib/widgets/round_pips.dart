import 'package:flutter/material.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../models/skulking_state.dart';

class RoundPips extends StatelessWidget {
  const RoundPips({
    super.key,
    required this.currentRound,
    required this.maxVisitedRound,
    required this.hasDoneRound,
    required this.onTap,
  });

  final int currentRound;
  final int maxVisitedRound;
  final bool Function(int round) hasDoneRound;
  final void Function(int round) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(kMaxRounds, (i) {
        final r = i + 1;
        final locked = r > maxVisitedRound;
        final isCurrent = r == currentRound;
        final isDone = !locked && hasDoneRound(r);

        Color bg;
        Color border;
        if (isCurrent) {
          bg = AppColors.gold;
          border = AppColors.goldBright;
        } else if (isDone) {
          bg = AppColors.gold.withOpacity(0.25);
          border = AppColors.gold.withOpacity(0.5);
        } else if (locked) {
          bg = AppColors.card;
          border = AppColors.border;
        } else {
          bg = AppColors.card;
          border = AppColors.gold.withOpacity(0.4);
        }

        return GestureDetector(
          onTap: locked ? null : () => onTap(r),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              '$r',
              style: AppTextStyles.body.copyWith(
                color: isCurrent ? AppColors.background : AppColors.text,
                fontWeight: isCurrent ? FontWeight.bold : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
