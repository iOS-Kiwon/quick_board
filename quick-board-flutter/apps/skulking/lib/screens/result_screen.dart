import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../l10n/app_localizations.dart';
import '../models/skulking_state.dart';
import '../notifiers/skulking_notifier.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final GlobalKey _captureKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(skulkingProvider);
    final standings = _buildStandings(state);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      bottomNavigationBar: const AdBannerWidget(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RepaintBoundary(
              key: _captureKey,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      l.finalResult,
                      style: AppTextStyles.heading,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _PodiumRow(standings: standings),
                    const SizedBox(height: 24),
                    _ResultTable(state: state),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(
                  builder: (btnContext) => AppButton(
                    label: _isSharing ? l.sharingPreparing : l.shareResult,
                    variant: AppButtonVariant.ghost,
                    onPressed: _isSharing
                        ? null
                        : () => _shareScreenshot(btnContext, l),
                  ),
                ),
                const SizedBox(width: 12),
                AppButton(
                  label: l.playAgain,
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

  Future<void> _shareScreenshot(BuildContext btnContext, AppLocalizations l) async {
    setState(() => _isSharing = true);
    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('[Share] RepaintBoundary not found');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();
      if (pngBytes == null) {
        debugPrint('[Share] PNG bytes null');
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/skulking_result_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      final box = btnContext.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: l.shareSubject,
        sharePositionOrigin: origin,
      );
      debugPrint('[Share] status: ${result.status}');
    } catch (e, st) {
      debugPrint('[Share] 실패: $e\n$st');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }
}

class _PodiumRow extends StatelessWidget {
  const _PodiumRow({required this.standings});

  final List<({String name, int total, int rank})> standings;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    const emojis = ['🥇', '🥈', '🥉'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: standings.map((s) {
        final rankEmoji = s.rank <= 3 ? emojis[s.rank - 1] : l.rankLabel(s.rank);
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
    final l = AppLocalizations.of(context)!;

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
                DataColumn(label: Text(l.roundHeader, style: AppTextStyles.bodyDim)),
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
                    DataCell(Text(l.roundPrefix(r), style: AppTextStyles.bodyDim)),
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
                    DataCell(Text(l.shareTotal, style: AppTextStyles.subheading)),
                    ...totals.map((t) => DataCell(ScoreCard(score: t))),
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
