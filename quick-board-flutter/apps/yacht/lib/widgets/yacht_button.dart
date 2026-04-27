import 'package:flutter/material.dart';
import '../theme/yacht_colors.dart';
import '../theme/yacht_text_styles.dart';

class YachtButton extends StatelessWidget {
  const YachtButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSecondary ? YachtColors.card : YachtColors.primary;
    final borderColor = isSecondary ? YachtColors.border : YachtColors.primary;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label, style: YachtTextStyles.button),
      ),
    );
  }
}
