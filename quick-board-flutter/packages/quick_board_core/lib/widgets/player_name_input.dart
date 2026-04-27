import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class PlayerNameInput extends StatelessWidget {
  const PlayerNameInput({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 12,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
      ),
    );
  }
}
