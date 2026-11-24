import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'session_controller.dart';

class AccountChoice {
  const AccountChoice({
    required this.type,
    required this.title,
    required this.detail,
  });

  final String type;
  final String title;
  final String detail;
}

const accountChoices = [
  AccountChoice(
    type: 'client',
    title: 'Client',
    detail: 'More than one center, separate data',
  ),
  AccountChoice(
    type: 'trainer',
    title: 'PT',
    detail: 'One branch, many clients',
  ),
  AccountChoice(
    type: 'manager',
    title: 'Manager',
    detail: 'One center, several branches',
  ),
  AccountChoice(
    type: 'center',
    title: 'Fitness center',
    detail: 'You become the super admin now',
  ),
];

class RegisterChoiceScreen extends StatelessWidget {
  const RegisterChoiceScreen({
    required this.onChoice,
    required this.onBack,
    super.key,
  });

  final ValueChanged<AccountChoice> onChoice;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            const Text(
              'Create account',
              style: TextStyle(
                color: AppColors.paper,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A menu opens only after an invite.',
              style: TextStyle(color: AppColors.muted, fontSize: 16),
            ),
            const SizedBox(height: 24),
            for (final choice in accountChoices) ...[
              _Choice(choice: choice, onTap: () => onChoice(choice)),
              const SizedBox(height: 12),
            ],
            TextButton(onPressed: onBack, child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.choice, required this.onTap});

  final AccountChoice choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                choice.title,
                style: const TextStyle(
                  color: AppColors.paper,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                choice.detail,
                style: const TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({
    required this.choice,
    required this.session,
    super.key,
  });

  final AccountChoice choice;
  final SessionController session;

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.session.register(
        email: _email.text,
        password: _password.text,
        displayName: _name.text,
        accountType: widget.choice.type,
      );
    } on Object catch (err) {
      _error = err is Exception
          ? 'Check the name, email, and password.'
          : 'Check the name, email, and password.';
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
              'Your account',
              style: TextStyle(
                color: AppColors.paper,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Client, PT, or manager. No menu yet.',
              style: TextStyle(color: AppColors.muted, fontSize: 16),
            ),
            const SizedBox(height: 24),
            AppTextField(label: 'Name', hint: 'Maya Chen', controller: _name),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email',
              hint: 'maya@harbor.club',
              controller: _email,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Password',
              hint: 'At least 8 characters',
              controller: _password,
              obscureText: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.clay)),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Create account',
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
