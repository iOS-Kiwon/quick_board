import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final style = score > 0
        ? AppTextStyles.scorePositive
        : score < 0
            ? AppTextStyles.scoreNegative
            : AppTextStyles.scoreZero;

    final label = score > 0 ? '+$score' : '$score';

    return Text(label, style: style);
  }
}
