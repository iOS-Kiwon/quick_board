import 'package:flutter/material.dart';
import 'package:quick_board_core/quick_board_core.dart';
import '../l10n/app_localizations.dart';
import '../models/player_score.dart';

class ScoreInputTable extends StatefulWidget {
  const ScoreInputTable({
    super.key,
    required this.players,
    required this.currentRound,
    required this.savedScores,
    required this.onScoreChanged,
  });

  final List<String> players;
  final int currentRound;
  final Map<int, PlayerScore?> savedScores;
  final void Function(int playerIndex, PlayerScore score) onScoreChanged;

  @override
  State<ScoreInputTable> createState() => _ScoreInputTableState();
}

class _ScoreInputTableState extends State<ScoreInputTable> {
  late final List<TextEditingController> _bidCtrl;
  late final List<TextEditingController> _tricksCtrl;
  late final List<TextEditingController> _bonusCtrl;
  late final FocusNode _firstBidFocus;

  @override
  void initState() {
    super.initState();
    _firstBidFocus = FocusNode();
    _bidCtrl = List.generate(widget.players.length, (i) {
      final s = widget.savedScores[i];
      return TextEditingController(text: s != null ? '${s.predictedWins}' : '');
    });
    _tricksCtrl = List.generate(widget.players.length, (i) {
      final s = widget.savedScores[i];
      return TextEditingController(text: s != null ? '${s.actualWins}' : '');
    });
    _bonusCtrl = List.generate(widget.players.length, (i) {
      final s = widget.savedScores[i];
      return TextEditingController(text: s != null && s.bonus != 0 ? '${s.bonus}' : '');
    });
  }

  @override
  void didUpdateWidget(ScoreInputTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRound != widget.currentRound) {
      for (var i = 0; i < widget.players.length; i++) {
        _bidCtrl[i].clear();
        _tricksCtrl[i].clear();
        _bonusCtrl[i].clear();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _firstBidFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _firstBidFocus.dispose();
    for (final c in [..._bidCtrl, ..._tricksCtrl, ..._bonusCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onInput(int i) {
    final bidText = _bidCtrl[i].text;
    if (bidText.isEmpty) return;

    final r = widget.currentRound;
    final bid = (int.tryParse(bidText) ?? 0).clamp(0, r);
    final tricks = (int.tryParse(_tricksCtrl[i].text) ?? 0).clamp(0, r);
    final bonus = int.tryParse(_bonusCtrl[i].text) ?? 0;

    if (_bidCtrl[i].text != '$bid') {
      _bidCtrl[i].text = '$bid';
      _bidCtrl[i].selection = TextSelection.collapsed(offset: '$bid'.length);
    }
    if (_tricksCtrl[i].text != '$tricks') {
      _tricksCtrl[i].text = '$tricks';
      _tricksCtrl[i].selection = TextSelection.collapsed(offset: '$tricks'.length);
    }

    final score = PlayerScore(
      predictedWins: bid,
      actualWins: tricks,
      bonus: bonus,
      round: r,
    );
    widget.onScoreChanged(i, score);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      children: [
        _headerRow(l),
        const Divider(height: 1, color: AppColors.border),
        ...List.generate(widget.players.length, (i) => _playerRow(i)),
      ],
    );
  }

  Widget _headerRow(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              l.playerHeader,
              style: AppTextStyles.bodyDim,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              l.predictedWins,
              style: AppTextStyles.bodyDim,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              l.actualWins,
              style: AppTextStyles.bodyDim,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              l.bonus,
              style: AppTextStyles.bodyDim,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              l.roundScore,
              style: AppTextStyles.bodyDim,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerRow(int i) {
    final saved = widget.savedScores[i];
    final bonusApplies = saved != null &&
        saved.predictedWins > 0 &&
        saved.predictedWins == saved.actualWins;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              widget.players[i],
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: _numberField(
              _bidCtrl[i],
              i,
              focusNode: i == 0 ? _firstBidFocus : null,
            ),
          ),
          Expanded(child: _numberField(_tricksCtrl[i], i)),
          Expanded(
            child: Opacity(
              opacity: bonusApplies ? 1.0 : 0.35,
              child: _numberField(_bonusCtrl[i], i),
            ),
          ),
          Expanded(
            child: Center(
              child: saved != null
                  ? ScoreCard(score: saved.roundScore)
                  : Text('—', style: AppTextStyles.bodyDim),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberField(
    TextEditingController ctrl,
    int playerIndex, {
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: ctrl,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        style: AppTextStyles.body,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 6),
          isDense: true,
        ),
        onChanged: (_) => _onInput(playerIndex),
      ),
    );
  }
}
