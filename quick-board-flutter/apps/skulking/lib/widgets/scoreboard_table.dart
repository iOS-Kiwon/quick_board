import 'package:flutter/material.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../models/player_score.dart';
import '../models/skulking_state.dart';

class ScoreboardTable extends StatelessWidget {
  const ScoreboardTable({
    super.key,
    required this.players,
    required this.scores,
    required this.currentRound,
    required this.totalScores,
  });

  final List<String> players;
  final Map<int, Map<int, PlayerScore>> scores;
  final int currentRound;
  final List<int> totalScores;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Center(
            child: DataTable(
              headingTextStyle: AppTextStyles.bodyDim,
              dataTextStyle: AppTextStyles.body,
              columnSpacing: 12,
              columns: [
                DataColumn(label: Text('라운드', style: AppTextStyles.bodyDim)),
                ...players.map((p) => DataColumn(
                      label: Text(p, style: AppTextStyles.bodyDim),
                      numeric: true,
                    )),
              ],
              rows: [
                ...List.generate(kMaxRounds, (i) {
                  final r = i + 1;
                  final isCurrent = r == currentRound;
                  return DataRow(
                    color: isCurrent
                        ? WidgetStateProperty.all(
                            AppColors.gold.withOpacity(0.08))
                        : null,
                    cells: [
                      DataCell(Text('R$r',
                          style: isCurrent
                              ? AppTextStyles.body
                                  .copyWith(color: AppColors.goldBright)
                              : AppTextStyles.bodyDim)),
                      ...List.generate(players.length, (pi) {
                        final s = scores[pi]?[r];
                        return DataCell(
                          s != null
                              ? ScoreCard(score: s.roundScore)
                              : Text('—', style: AppTextStyles.bodyDim),
                        );
                      }),
                    ],
                  );
                }),
                DataRow(
                  color: WidgetStateProperty.all(AppColors.card),
                  cells: [
                    DataCell(Text('합계', style: AppTextStyles.subheading)),
                    ...totalScores.map((t) => DataCell(ScoreCard(score: t))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
