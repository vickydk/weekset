import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import 'session_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.session,
    required this.onForgot,
    required this.onBack,
    super.key,
  });

  final SessionController session;
  final VoidCallback onForgot;
  final VoidCallback onBack;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.session.removeListener(_changed);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await widget.session.login(email: _email.text, password: _password.text);
    } on Object {
      // The controller keeps the message.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            const Text(
              'Log in',
              style: TextStyle(
                color: AppColors.paper,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use the email you registered.',
              style: TextStyle(color: AppColors.muted, fontSize: 16),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Email',
              hint: 'maya@harbor.club',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Password',
              hint: 'Password',
              controller: _password,
              obscureText: true,
            ),
            if (widget.session.error != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.session.error!,
                style: const TextStyle(color: AppColors.clay),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: _busy ? 'Log in' : 'Log in',
              onPressed: _busy ? null : _submit,
            ),
            SecondaryButton(
              label: 'Forgot password?',
              onPressed: widget.onForgot,
            ),
            SecondaryButton(label: 'Back', onPressed: widget.onBack),
          ],
        ),
      ),
    );
  }
}
