import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../models/skulking_state.dart';
import '../notifiers/skulking_notifier.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(skulkingProvider);
    final standings = _buildStandings(state);

    return Scaffold(
      bottomNavigationBar: const AdBannerWidget(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '🏆 최종 결과',
              style: AppTextStyles.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _PodiumRow(standings: standings),
            const SizedBox(height: 24),
            _ResultTable(state: state),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(
                  builder: (btnContext) => AppButton(
                    label: '📋 결과 공유',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => _share(btnContext, state, standings),
                  ),
                ),
                const SizedBox(width: 12),
                AppButton(
                  label: '🔄 다시 하기',
                  onPressed: () => context.go('/'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<({String name, int total, int rank})> _buildStandings(SkulkingState state) {
    final sorted = List.generate(state.players.length, (i) {
      return (name: state.players[i], total: state.totalScore(i));
    })
      ..sort((a, b) => b.total.compareTo(a.total));

    return List.generate(
      sorted.length,
      (i) => (name: sorted[i].name, total: sorted[i].total, rank: i + 1),
    );
  }

  Future<void> _share(
    BuildContext context,
    SkulkingState state,
    List<({String name, int total, int rank})> standings,
  ) async {
    const pad = 12;
    const scorePad = 8;
    final buf = StringBuffer();

    buf.writeln('☠️ 스컬킹 게임 결과 ☠️');
    buf.writeln(DateTime.now().toIso8601String().substring(0, 10));
    buf.writeln();
    buf.writeln('[ 최종 순위 ]');
    for (final s in standings) {
      final score = s.total > 0 ? '+${s.total}' : '${s.total}';
      buf.writeln('${s.rank}위  ${s.name.padRight(pad)}${score}점');
    }

    buf.writeln();
    buf.writeln('[ 라운드별 점수 ]');
    buf.write(''.padRight(pad));
    for (final p in state.players) {
      buf.write((p.length > 6 ? p.substring(0, 6) : p).padRight(scorePad));
    }
    buf.writeln();

    for (var r = 1; r <= kMaxRounds; r++) {
      final hasAny = state.players
          .asMap()
          .keys
          .any((i) => state.scores[i]?[r] != null);
      if (!hasAny) continue;

      buf.write('R$r'.padRight(pad));
      for (var i = 0; i < state.players.length; i++) {
        final s = state.scores[i]?[r];
        final label = s != null
            ? (s.roundScore > 0 ? '+${s.roundScore}' : '${s.roundScore}')
            : '—';
        buf.write(label.padRight(scorePad));
      }
      buf.writeln();
    }

    buf.write('합계'.padRight(pad));
    for (var i = 0; i < state.players.length; i++) {
      final t = state.totalScore(i);
      buf.write((t > 0 ? '+$t' : '$t').padRight(scorePad));
    }

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    try {
      final result = await Share.share(
        buf.toString(),
        subject: '스컬킹 게임 결과',
        sharePositionOrigin: origin,
      );
      debugPrint('[Share] status: ${result.status}');
    } catch (e, st) {
      debugPrint('[Share] 실패: $e\n$st');
    }
  }
}

class _PodiumRow extends StatelessWidget {
  const _PodiumRow({required this.standings});

  final List<({String name, int total, int rank})> standings;

  @override
  Widget build(BuildContext context) {
    const emojis = ['🥇', '🥈', '🥉'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: standings.map((s) {
        final rankEmoji = s.rank <= 3 ? emojis[s.rank - 1] : '${s.rank}위';
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rankEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(s.name, style: AppTextStyles.body),
            ScoreCard(score: s.total),
          ],
        );
      }).toList(),
    );
  }
}

class _ResultTable extends StatelessWidget {
  const _ResultTable({required this.state});

  final SkulkingState state;

  @override
  Widget build(BuildContext context) {
    final totals = List.generate(state.players.length, state.totalScore);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: AppTextStyles.bodyDim,
        dataTextStyle: AppTextStyles.body,
        columnSpacing: 12,
        columns: [
          DataColumn(label: Text('라운드', style: AppTextStyles.bodyDim)),
          ...state.players.map((p) => DataColumn(
                label: Text(p, style: AppTextStyles.bodyDim),
                numeric: true,
              )),
        ],
        rows: [
          ...List.generate(kMaxRounds, (i) {
            final r = i + 1;
            final hasAny = state.players
                .asMap()
                .keys
                .any((pi) => state.scores[pi]?[r] != null);
            if (!hasAny) return null;

            return DataRow(cells: [
              DataCell(Text('R$r', style: AppTextStyles.bodyDim)),
              ...List.generate(state.players.length, (pi) {
                final s = state.scores[pi]?[r];
                return DataCell(
                  s != null
                      ? ScoreCard(score: s.roundScore)
                      : Text('—', style: AppTextStyles.bodyDim),
                );
              }),
            ]);
          }).whereType<DataRow>().toList(),
          DataRow(
            color: WidgetStateProperty.all(AppColors.card),
            cells: [
              DataCell(Text('합계', style: AppTextStyles.subheading)),
              ...totals.map((t) => DataCell(ScoreCard(score: t))),
            ],
          ),
        ],
      ),
    );
  }
}
