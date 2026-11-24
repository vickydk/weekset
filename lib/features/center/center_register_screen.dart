import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../auth/session_controller.dart';

/// Opens the fitness center, the first branch, and the super-admin membership.
class CenterRegisterScreen extends StatefulWidget {
  const CenterRegisterScreen({required this.session, super.key});

  final SessionController session;

  @override
  State<CenterRegisterScreen> createState() => _CenterRegisterScreenState();
}

class _CenterRegisterScreenState extends State<CenterRegisterScreen> {
  final _center = TextEditingController();
  final _branch = TextEditingController();
  final _timezone = TextEditingController(text: 'Asia/Jakarta');
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _center.dispose();
    _branch.dispose();
    _timezone.dispose();
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
      final session = await widget.session.api.openCenter(
        email: _email.text,
        password: _password.text,
        displayName: _name.text,
        centerName: _center.text,
        branchName: _branch.text,
        timezone: _timezone.text,
      );
      await widget.session.adopt(session);
    } on Object {
      if (mounted) {
        setState(
          () => _error = 'Check the center, the branch, and the account.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
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
              'Open your center',
              style: TextStyle(
                color: AppColors.paper,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This account can invite managers right away.',
              style: TextStyle(color: AppColors.muted, fontSize: 16),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Center',
              hint: 'Harbor Club',
              controller: _center,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'First branch',
              hint: 'Downtown',
              controller: _branch,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Timezone',
              hint: 'Asia/Jakarta',
              controller: _timezone,
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Name', hint: 'Ada', controller: _name),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email',
              hint: 'ada@harbor.club',
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
              label: 'Create center',
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
