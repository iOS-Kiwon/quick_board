import 'package:flutter/material.dart';
import '../models/yacht_category.dart';
import '../models/yacht_state.dart';
import '../theme/yacht_colors.dart';
import '../theme/yacht_text_styles.dart';
import '../l10n/app_localizations.dart';

class ScoreSheetTable extends StatelessWidget {
  const ScoreSheetTable({
    super.key,
    required this.state,
    required this.onCategoryTap,
  });

  final YachtState state;
  final void Function(int playerIndex, YachtCategory category) onCategoryTap;

  static const double _categoryColWidth = 120;
  static const double _playerColWidth = 70;
  static const double _rowHeight = 44;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final players = state.players;

    final rows = [
      _headerRow(players, l),
      ...YachtCategory.values.where((c) => c.isUpper).map(
        (cat) => _categoryRow(cat, players, l, context),
      ),
      _autoRow(l.upperSubtotal, players, (i) => state.upperSubtotal(i).toString(), isSubtotal: true),
      _autoRow(l.bonusLabel, players, (i) {
        final b = state.bonus(i);
        return b > 0 ? '+$b' : '0';
      }, isBonus: true),
      const Divider(height: 1, thickness: 1, color: YachtColors.border),
      ...YachtCategory.values.where((c) => !c.isUpper).map(
        (cat) => _categoryRow(cat, players, l, context),
      ),
      _autoRow(l.totalScore, players, (i) => state.totalScore(i).toString(), isTotal: true),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(children: rows),
      ),
    );
  }

  Widget _headerRow(List<String> players, AppLocalizations l) {
    return Container(
      color: YachtColors.card,
      child: Row(
        children: [
          _cell(l.headerCategory, width: _categoryColWidth, style: YachtTextStyles.tableHeader),
          ...players.map(
            (name) => _cell(name, width: _playerColWidth, style: YachtTextStyles.tableHeader, overflow: true),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(
    YachtCategory cat,
    List<String> players,
    AppLocalizations l,
    BuildContext context,
  ) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: YachtColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          _cell(_categoryName(cat, l), width: _categoryColWidth, style: YachtTextStyles.categoryName),
          ...List.generate(players.length, (i) {
            final score = state.scores[i]?[cat];
            return GestureDetector(
              onTap: () => onCategoryTap(i, cat),
              child: _scoreCell(score),
            );
          }),
        ],
      ),
    );
  }

  Widget _autoRow(
    String label,
    List<String> players,
    String Function(int) getValue, {
    bool isSubtotal = false,
    bool isBonus = false,
    bool isTotal = false,
  }) {
    Color bg = YachtColors.background;
    TextStyle style = YachtTextStyles.body;

    if (isSubtotal) {
      bg = const Color(0xFF1A1414);
      style = YachtTextStyles.bodyDim;
    } else if (isBonus) {
      bg = const Color(0xFF1A1500);
      style = YachtTextStyles.bonus;
    } else if (isTotal) {
      bg = const Color(0xFF1A0808);
      style = YachtTextStyles.heading;
    }

    return Container(
      color: bg,
      child: Row(
        children: [
          _cell(label, width: _categoryColWidth, style: style),
          ...List.generate(players.length, (i) {
            return _cell(getValue(i), width: _playerColWidth, style: style);
          }),
        ],
      ),
    );
  }

  Widget _scoreCell(int? score) {
    return SizedBox(
      width: _playerColWidth,
      height: _rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: YachtColors.card,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: YachtColors.border),
          ),
          alignment: Alignment.center,
          child: score == null
              ? Text('—', style: YachtTextStyles.bodyDim.copyWith(fontSize: 14))
              : Text('$score', style: YachtTextStyles.score.copyWith(fontSize: 15)),
        ),
      ),
    );
  }

  Widget _cell(
    String text, {
    required double width,
    required TextStyle style,
    bool overflow = false,
  }) {
    return SizedBox(
      width: width,
      height: _rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: style,
            overflow: overflow ? TextOverflow.ellipsis : null,
            maxLines: 1,
          ),
        ),
      ),
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
