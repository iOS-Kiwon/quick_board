import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../l10n/app_localizations.dart';
import '../models/yacht_state.dart';
import '../notifiers/yacht_notifier.dart';
import '../theme/yacht_colors.dart';
import '../theme/yacht_text_styles.dart';
import '../theme/yacht_theme.dart';
import '../widgets/yacht_button.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _ResultBody(ranked: ranked, l: l),
              ),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (btnContext) => YachtButton(
                label: _isSharing ? '⏳ ...' : l.shareResult,
                onPressed: _isSharing
                    ? null
                    : () => _shareScreenshot(btnContext, ranked, l),
              ),
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

  Future<void> _shareScreenshot(
    BuildContext btnContext,
    List<(int rank, String name, int score)> ranked,
    AppLocalizations l,
  ) async {
    setState(() => _isSharing = true);
    try {
      final captureWidget = MediaQuery(
        data: MediaQuery.of(context),
        child: Theme(
          data: YachtTheme.dark,
          child: Material(
            color: YachtColors.background,
            child: _ResultBody(ranked: ranked, l: l),
          ),
        ),
      );

      final pngBytes = await _screenshotController.captureFromWidget(
        captureWidget,
        pixelRatio: 3.0,
        context: context,
        delay: const Duration(milliseconds: 50),
      );

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/yacht_result_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      final box = btnContext.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: l.appName,
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

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.ranked, required this.l});

  final List<(int rank, String name, int score)> ranked;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: YachtColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.finalResult, style: YachtTextStyles.appTitle),
          const SizedBox(height: 20),
          ...ranked.map((entry) {
            final (rank, name, score) = entry;
            return _RankRow(rank: rank, name: name, score: score, l: l);
          }),
        ],
      ),
    );
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
