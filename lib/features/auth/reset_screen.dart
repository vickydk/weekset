import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_api.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    required this.api,
    required this.onBack,
    super.key,
  });

  final AuthApi api;
  final VoidCallback onBack;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _email = TextEditingController();
  var _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      await widget.api.forgot(_email.text);
    } on Object {
      // The API answers the same way when the email is missing.
    }
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            const Text(
              'Reset password',
              style: TextStyle(
                color: AppColors.paper,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We will email you a link. It expires the same day.',
              style: TextStyle(color: AppColors.muted, fontSize: 16),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Email',
              hint: 'maya@harbor.club',
              controller: _email,
            ),
            if (_sent) ...[
              const SizedBox(height: 12),
              const Text(
                'If that email is registered, the link is on its way.',
                style: TextStyle(color: AppColors.paper),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(label: 'Send reset link', onPressed: _submit),
            TextButton(
              onPressed: widget.onBack,
              child: const Text('Back to log in'),
            ),
          ],
        ),
      ),
    );
  }
}
