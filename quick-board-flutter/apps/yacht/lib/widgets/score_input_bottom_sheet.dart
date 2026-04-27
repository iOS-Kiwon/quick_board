import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/yacht_category.dart';
import '../theme/yacht_colors.dart';
import '../theme/yacht_text_styles.dart';
import '../l10n/app_localizations.dart';

class _FixedScoreButton extends StatelessWidget {
  const _FixedScoreButton({
    required this.label,
    required this.score,
    required this.isSelected,
    required this.isSuccess,
    required this.onTap,
  });

  final String label;
  final int score;
  final bool isSelected;
  final bool isSuccess;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? (isSuccess ? YachtColors.scorePositive : YachtColors.textDim)
        : YachtColors.border;
    final bgColor = isSelected
        ? (isSuccess
            ? YachtColors.scorePositive.withValues(alpha: 0.15)
            : YachtColors.card)
        : YachtColors.card;
    final textColor = isSuccess ? YachtColors.scorePositive : YachtColors.textDim;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: YachtTextStyles.button.copyWith(color: textColor, fontSize: 16),
        ),
      ),
    );
  }
}

class ScoreInputBottomSheet extends StatefulWidget {
  const ScoreInputBottomSheet({
    super.key,
    required this.category,
    required this.categoryName,
    required this.currentScore,
    required this.onConfirm,
  });

  final YachtCategory category;
  final String categoryName;
  final int? currentScore;
  final void Function(int score) onConfirm;

  static Future<void> show({
    required BuildContext context,
    required YachtCategory category,
    required String categoryName,
    required int? currentScore,
    required void Function(int score) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: YachtColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (_) => ScoreInputBottomSheet(
        category: category,
        categoryName: categoryName,
        currentScore: currentScore,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<ScoreInputBottomSheet> createState() => _ScoreInputBottomSheetState();
}

class _ScoreInputBottomSheetState extends State<ScoreInputBottomSheet> {
  late final TextEditingController _controller;
  bool _willAutoConvert = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentScore?.toString() ?? '',
    );
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final value = int.tryParse(_controller.text);
    setState(() {
      _willAutoConvert = value != null && value > widget.category.maxScore;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fixedScore = widget.category.fixedScore;

    if (fixedScore != null) {
      return _buildFixedScoreSheet(context, fixedScore, l);
    }
    return _buildFreeInputSheet(context, l);
  }

  Widget _buildFixedScoreSheet(BuildContext context, int fixedScore, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.categoryName, style: YachtTextStyles.heading),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _FixedScoreButton(
                  label: '✗  0점',
                  score: 0,
                  isSelected: widget.currentScore == 0,
                  isSuccess: false,
                  onTap: () {
                    widget.onConfirm(0);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FixedScoreButton(
                  label: '✓  ${fixedScore}점',
                  score: fixedScore,
                  isSelected: widget.currentScore == fixedScore,
                  isSuccess: true,
                  onTap: () {
                    widget.onConfirm(fixedScore);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: YachtColors.border),
                foregroundColor: YachtColors.textDim,
              ),
              child: Text(l.cancelButton, style: YachtTextStyles.button.copyWith(color: YachtColors.textDim)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeInputSheet(BuildContext context, AppLocalizations l) {
    final insets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, insets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.categoryName, style: YachtTextStyles.heading),
          const SizedBox(height: 4),
          Text(
            l.maxScoreHint(widget.category.maxScore),
            style: YachtTextStyles.bodyDim,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: YachtTextStyles.body,
            decoration: InputDecoration(hintText: l.scoreInputHint),
          ),
          if (_willAutoConvert) ...[
            const SizedBox(height: 8),
            Text(
              l.autoConverted(widget.category.maxScore),
              style: YachtTextStyles.bodyDim.copyWith(color: YachtColors.primaryBright),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: YachtColors.border),
                    foregroundColor: YachtColors.textDim,
                  ),
                  child: Text(l.cancelButton, style: YachtTextStyles.button.copyWith(color: YachtColors.textDim)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onFreeConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: YachtColors.primary,
                    foregroundColor: YachtColors.text,
                  ),
                  child: Text(l.confirmButton, style: YachtTextStyles.button),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onFreeConfirm() {
    final value = int.tryParse(_controller.text) ?? 0;
    widget.onConfirm(value);
    Navigator.of(context).pop();
  }
}
