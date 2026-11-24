import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/context_header.dart';
import '../../core/widgets/locked_screen.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/suspended_screen.dart';
import '../../core/widgets/week_mark.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'reset_screen.dart';
import 'session_controller.dart';
import 'welcome_screen.dart';

enum _Step { welcome, login, reset, choices, account, center, code }

/// Chooses welcome, locked, suspended, or the role shell from /v1/me.
class AuthGate extends StatefulWidget {
  const AuthGate({required this.session, super.key});

  final SessionController session;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  _Step _step = _Step.welcome;
  AccountChoice? _choice;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.session,
      builder: (context, _) {
        final session = widget.session;
        if (session.gate == Gate.loading) {
          return const Scaffold(body: Center(child: WeekMark()));
        }
        if (session.gate == Gate.locked) {
          if (_step == _Step.code) return const InviteCodeStub();
          return LockedScreen(
            onHaveCode: () => setState(() => _step = _Step.code),
            onSignOut: () {
              setState(() => _step = _Step.welcome);
              session.signOut();
            },
          );
        }
        if (session.gate == Gate.suspended) {
          return SuspendedScreen(
            centerName: session.profile?.memberships.first.centerName ?? '',
            onSignOut: session.signOut,
          );
        }
        if (session.gate == Gate.shell) {
          return RoleShell(session: session);
        }
        return switch (_step) {
          _Step.welcome => WelcomeScreen(
            onLogIn: () => setState(() => _step = _Step.login),
            onCreateAccount: () => setState(() => _step = _Step.choices),
          ),
          _Step.login => LoginScreen(
            session: session,
            onBack: () => setState(() => _step = _Step.welcome),
            onForgot: () => setState(() => _step = _Step.reset),
          ),
          _Step.reset => ResetPasswordScreen(
            api: session.api,
            onBack: () => setState(() => _step = _Step.login),
          ),
          _Step.choices => RegisterChoiceScreen(
            onBack: () => setState(() => _step = _Step.welcome),
            onChoice: (choice) => setState(() {
              _choice = choice;
              _step = choice.type == 'center' ? _Step.center : _Step.account;
            }),
          ),
          _Step.account => RegisterAccountScreen(
            choice: _choice!,
            session: session,
          ),
          _Step.center => const CenterRegisterPlaceholder(),
          _Step.code => const InviteCodeStub(),
        };
      },
    );
  }
}

/// A menu for one active membership. The four tab bars arrive with the menus ticket.
class RoleShell extends StatelessWidget {
  const RoleShell({required this.session, super.key});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    final membership = session.profile?.activeMembership;
    final role = switch (membership?.role) {
      'trainer' => 'PT',
      'manager' => 'Manager',
      'center_admin' => 'Center',
      _ => 'Client',
    };
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContextHeader(
                centerName: membership?.centerName ?? '',
                branchName: membership?.branchName,
              ),
              const SizedBox(height: 24),
              Text(
                role,
                style: const TextStyle(
                  color: AppColors.paper,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              SecondaryButton(label: 'Sign out', onPressed: session.signOut),
            ],
          ),
        ),
      ),
    );
  }
}
