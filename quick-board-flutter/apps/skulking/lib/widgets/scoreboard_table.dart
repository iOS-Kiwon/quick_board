import 'package:flutter/material.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../l10n/app_localizations.dart';
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

  static const double _roundColumnWidth = 50.0;
  static const double _minPlayerColumnWidth = 64.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final minTotal = _roundColumnWidth + _minPlayerColumnWidth * players.length;

        if (available >= minTotal) {
          // 화면 폭에 꽉 차도록 분배
          final playerColWidth =
              (available - _roundColumnWidth) / players.length;
          return _buildTable(l, playerColWidth: playerColWidth, totalWidth: available);
        }

        // 가로 스크롤 모드
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: minTotal,
            child: _buildTable(
              l,
              playerColWidth: _minPlayerColumnWidth,
              totalWidth: minTotal,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTable(
    AppLocalizations l, {
    required double playerColWidth,
    required double totalWidth,
  }) {
    return Column(
      children: [
        _headerRow(l, playerColWidth: playerColWidth),
        const Divider(height: 1, color: AppColors.border),
        ...List.generate(kMaxRounds, (i) {
          final r = i + 1;
          return _roundRow(r, playerColWidth: playerColWidth);
        }),
        Container(
          color: AppColors.card,
          child: _totalRow(l, playerColWidth: playerColWidth),
        ),
      ],
    );
  }

  Widget _headerRow(AppLocalizations l, {required double playerColWidth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: _roundColumnWidth,
            child: Text(
              l.roundHeader,
              style: AppTextStyles.bodyDim,
              textAlign: TextAlign.center,
            ),
          ),
          ...players.map(
            (p) => SizedBox(
              width: playerColWidth,
              child: Text(
                p,
                style: AppTextStyles.bodyDim,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundRow(int r, {required double playerColWidth}) {
    final isCurrent = r == currentRound;
    return Container(
      color: isCurrent ? AppColors.gold.withOpacity(0.08) : null,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: _roundColumnWidth,
            child: Text(
              'R$r',
              style: isCurrent
                  ? AppTextStyles.body.copyWith(color: AppColors.goldBright)
                  : AppTextStyles.bodyDim,
              textAlign: TextAlign.center,
            ),
          ),
          ...List.generate(players.length, (pi) {
            final s = scores[pi]?[r];
            return SizedBox(
              width: playerColWidth,
              child: Center(
                child: s != null
                    ? ScoreCard(score: s.roundScore)
                    : Text('—', style: AppTextStyles.bodyDim),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _totalRow(AppLocalizations l, {required double playerColWidth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: _roundColumnWidth,
            child: Text(
              l.shareTotal,
              style: AppTextStyles.subheading,
              textAlign: TextAlign.center,
            ),
          ),
          ...totalScores.map(
            (t) => SizedBox(
              width: playerColWidth,
              child: Center(child: ScoreCard(score: t)),
            ),
          ),
        ],
      ),
    );
  }
}
