import 'package:flutter/material.dart';
import 'package:quick_board_core/quick_board_core.dart';
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: AppTextStyles.bodyDim,
        dataTextStyle: AppTextStyles.body,
        columnSpacing: 12,
        columns: [
          DataColumn(label: Text('플레이어', style: AppTextStyles.bodyDim)),
          DataColumn(label: Text('예측승', style: AppTextStyles.bodyDim), numeric: true),
          DataColumn(label: Text('획득승', style: AppTextStyles.bodyDim), numeric: true),
          DataColumn(label: Text('보너스', style: AppTextStyles.bodyDim), numeric: true),
          DataColumn(label: Text('점수', style: AppTextStyles.bodyDim), numeric: true),
        ],
        rows: List.generate(widget.players.length, (i) {
          final saved = widget.savedScores[i];
          final bonusApplies = saved != null &&
              saved.predictedWins > 0 &&
              saved.predictedWins == saved.actualWins;

          return DataRow(cells: [
            DataCell(Text(widget.players[i])),
            DataCell(_numberField(_bidCtrl[i], i, focusNode: i == 0 ? _firstBidFocus : null)),
            DataCell(_numberField(_tricksCtrl[i], i)),
            DataCell(
              Opacity(
                opacity: bonusApplies ? 1.0 : 0.35,
                child: _numberField(_bonusCtrl[i], i),
              ),
            ),
            DataCell(
              saved != null
                  ? ScoreCard(score: saved.roundScore)
                  : Text('—', style: AppTextStyles.bodyDim),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _numberField(TextEditingController ctrl, int playerIndex, {FocusNode? focusNode}) {
    return SizedBox(
      width: 70,
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
