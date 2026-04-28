import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../models/player_score.dart';
import '../models/skulking_state.dart';
import '../notifiers/skulking_notifier.dart';
import '../widgets/round_pips.dart';
import '../widgets/score_input_table.dart';
import '../widgets/scoreboard_table.dart';
import '../widgets/tricks_sum_indicator.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(skulkingProvider);
    final notifier = ref.read(skulkingProvider.notifier);
    final r = state.currentRound;
    final isOnLatest = r == state.maxVisitedRound;
    final canAdvance = state.isSumValid && isOnLatest && r < kMaxRounds;

    final savedScores = <int, PlayerScore?>{
      for (var i = 0; i < state.players.length; i++)
        i: state.scores[i]?[r],
    };

    final totals = List.generate(
      state.players.length,
      state.totalScore,
    );

    return Scaffold(
      bottomNavigationBar: const AdBannerWidget(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppColors.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$r / $kMaxRounds',
                          style: AppTextStyles.heading,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: r > 1
                              ? () => notifier.goToRound(r - 1)
                              : null,
                          icon: const Icon(Icons.arrow_back_ios),
                          color: AppColors.gold,
                        ),
                        IconButton(
                          onPressed: r < state.maxVisitedRound
                              ? () => notifier.goToRound(r + 1)
                              : null,
                          icon: const Icon(Icons.arrow_forward_ios),
                          color: AppColors.gold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RoundPips(
                      currentRound: r,
                      maxVisitedRound: state.maxVisitedRound,
                      hasDoneRound: (round) =>
                          state.scores.values.any((m) => m.containsKey(round)),
                      onTap: notifier.goToRound,
                    ),
                    const SizedBox(height: 16),
                    ScoreInputTable(
                      players: state.players,
                      currentRound: r,
                      savedScores: savedScores,
                      onScoreChanged: (i, score) =>
                          notifier.updateScore(i, r, score),
                    ),
                    const SizedBox(height: 12),
                    TricksSumIndicator(
                      sum: state.actualWinsSum(),
                      round: r,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (canAdvance)
                          AppButton(
                            label: '다음 라운드 ▶',
                            onPressed: notifier.advanceRound,
                          ),
                        const SizedBox(width: 12),
                        AppButton(
                          label: '🏁 게임 종료',
                          variant: AppButtonVariant.danger,
                          onPressed: () => context.go('/result'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📊 누적 총점', style: AppTextStyles.subheading),
                    const SizedBox(height: 12),
                    ScoreboardTable(
                      players: state.players,
                      scores: state.scores,
                      currentRound: r,
                      totalScores: totals,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
