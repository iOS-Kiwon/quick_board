import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../l10n/app_localizations.dart';
import '../models/yacht_state.dart';
import '../notifiers/yacht_notifier.dart';
import '../theme/yacht_colors.dart';
import '../theme/yacht_text_styles.dart';
import '../widgets/yacht_button.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(yachtProvider);

    if (state.players.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const SizedBox.shrink();
    }

    final ranked = _rankPlayers(state);

    return Scaffold(
      backgroundColor: YachtColors.background,
      bottomNavigationBar: const AdBannerWidget(),
      appBar: AppBar(
        title: Text(l.appName),
        backgroundColor: YachtColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.finalResult, style: YachtTextStyles.appTitle),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: ranked.length,
                itemBuilder: (context, i) {
                  final (rank, name, score) = ranked[i];
                  return _RankRow(
                    rank: rank,
                    name: name,
                    score: score,
                    l: l,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            YachtButton(
              label: l.shareResult,
              onPressed: () => _share(state, l),
            ),
            const SizedBox(height: 10),
            YachtButton(
              label: l.playAgain,
              isSecondary: true,
              onPressed: () {
                ref.read(yachtProvider.notifier).resetGame();
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }

  List<(int rank, String name, int score)> _rankPlayers(YachtState state) {
    final scores = List.generate(
      state.players.length,
      (i) => (i, state.players[i], state.totalScore(i)),
    );
    scores.sort((a, b) => b.$3.compareTo(a.$3));

    int rank = 1;
    return List.generate(scores.length, (i) {
      if (i > 0 && scores[i].$3 < scores[i - 1].$3) rank = i + 1;
      return (rank, scores[i].$2, scores[i].$3);
    });
  }

  void _share(YachtState state, AppLocalizations l) {
    final buf = StringBuffer();
    buf.writeln(l.shareHeader);
    buf.writeln();
    buf.writeln(l.shareFinalStandings);

    final ranked = _rankPlayers(state);
    for (final (rank, name, score) in ranked) {
      buf.writeln('${l.rankLabel(rank)} $name — ${l.pointsSuffix(score.toString())}');
    }

    buf.writeln();
    buf.writeln(l.shareRoundScores);

    for (int i = 0; i < state.players.length; i++) {
      buf.writeln('\n${state.players[i]}');
      buf.writeln('  ${l.shareUpperSubtotal}: ${state.upperSubtotal(i)}');
      buf.writeln('  ${l.shareBonus}: ${state.bonus(i)}');
      buf.writeln('  ${l.shareTotal}: ${state.totalScore(i)}');
    }

    Share.share(buf.toString());
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.name,
    required this.score,
    required this.l,
  });

  final int rank;
  final String name;
  final int score;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isFirst ? const Color.fromARGB(40, 0xCC, 0x22, 0x22) : YachtColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFirst ? YachtColors.primary : YachtColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              l.rankLabel(rank),
              style: isFirst
                  ? YachtTextStyles.heading.copyWith(color: YachtColors.primaryBright)
                  : YachtTextStyles.bodyDim,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: isFirst
                  ? YachtTextStyles.heading
                  : YachtTextStyles.body,
            ),
          ),
          Text(
            l.pointsSuffix(score.toString()),
            style: YachtTextStyles.score,
          ),
        ],
      ),
    );
  }
}
