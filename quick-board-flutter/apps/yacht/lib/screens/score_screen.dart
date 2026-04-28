import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../l10n/app_localizations.dart';
import '../models/yacht_category.dart';
import '../models/yacht_state.dart';
import '../notifiers/yacht_notifier.dart';
import '../theme/yacht_colors.dart';
import '../theme/yacht_text_styles.dart';
import '../widgets/score_sheet_table.dart';
import '../widgets/score_input_bottom_sheet.dart';
import '../widgets/yacht_button.dart';

class ScoreScreen extends ConsumerWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(yachtProvider);

    if (state.players.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: YachtColors.background,
      bottomNavigationBar: const AdBannerWidget(),
      appBar: AppBar(
        title: Text(l.appName),
        backgroundColor: YachtColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ScoreSheetTable(
              state: state,
              onCategoryTap: (playerIndex, category) =>
                  _openScoreInput(context, ref, state, playerIndex, category, l),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: YachtButton(
              label: l.endGame,
              onPressed: () => context.go('/result'),
            ),
          ),
        ],
      ),
    );
  }

  int _countFilled(YachtState state) {
    int count = 0;
    for (int i = 0; i < state.players.length; i++) {
      count += (state.scores[i]?.length ?? 0);
    }
    return count;
  }

  void _openScoreInput(
    BuildContext context,
    WidgetRef ref,
    YachtState state,
    int playerIndex,
    YachtCategory category,
    AppLocalizations l,
  ) {
    final categoryName = _categoryName(category, l);
    final currentScore = state.scores[playerIndex]?[category];

    ScoreInputBottomSheet.show(
      context: context,
      category: category,
      categoryName: '${state.players[playerIndex]} - $categoryName',
      currentScore: currentScore,
      onConfirm: (score) {
        ref.read(yachtProvider.notifier).enterScore(playerIndex, category, score);
      },
    );
  }

  String _categoryName(YachtCategory cat, AppLocalizations l) => switch (cat) {
    YachtCategory.aces => l.catAces,
    YachtCategory.duals => l.catDuals,
    YachtCategory.triples => l.catTriples,
    YachtCategory.quads => l.catQuads,
    YachtCategory.penta => l.catPenta,
    YachtCategory.hexa => l.catHexa,
    YachtCategory.choice => l.catChoice,
    YachtCategory.poker => l.catPoker,
    YachtCategory.fullHouse => l.catFullHouse,
    YachtCategory.smallStraight => l.catSmallStraight,
    YachtCategory.largeStraight => l.catLargeStraight,
    YachtCategory.yacht => l.catYacht,
  };
}
