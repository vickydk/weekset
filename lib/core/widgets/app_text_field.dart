import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Label above a card field. The hint is the example, not the label.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.paper, fontSize: 16),
          cursorColor: AppColors.lime,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
