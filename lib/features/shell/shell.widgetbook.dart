import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_chip.dart';
import '../auth/auth_api.dart';
import '../auth/session_controller.dart';
import '../auth/token_store.dart';
import '../home/home_card.dart';
import 'role_shell.dart';

WidgetbookFolder shellFolder() {
  return WidgetbookFolder(
    name: 'Shells',
    children: [
      WidgetbookComponent(
        name: 'Client',
        useCases: [
          WidgetbookUseCase(
            name: 'empty',
            builder: (context) => _shell('client', 'Harbor Club'),
          ),
          WidgetbookUseCase(name: 'filled', builder: _filled),
          WidgetbookUseCase(name: 'two centers', builder: _twoCenters),
        ],
      ),
      WidgetbookComponent(
        name: 'PT',
        useCases: [
          WidgetbookUseCase(
            name: 'empty',
            builder: (context) =>
                _shell('trainer', 'Harbor Club', branch: 'Downtown'),
          ),
          WidgetbookUseCase(
            name: 'filled',
            builder: (context) => _shell(
              'trainer',
              'Harbor Club',
              branch: 'Downtown',
              filled: true,
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Manager',
        useCases: [
          WidgetbookUseCase(
            name: 'empty',
            builder: (context) =>
                _shell('manager', 'Harbor Club', branch: 'Downtown'),
          ),
          WidgetbookUseCase(
            name: 'filled',
            builder: (context) => _shell(
              'manager',
              'Harbor Club',
              branch: 'Downtown',
              filled: true,
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Center',
        useCases: [
          WidgetbookUseCase(
            name: 'empty',
            builder: (context) =>
                _shell('center_admin', 'Harbor Club', branch: 'Downtown'),
          ),
          WidgetbookUseCase(
            name: 'filled',
            builder: (context) => _shell(
              'center_admin',
              'Harbor Club',
              branch: 'Downtown',
              filled: true,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _filled(BuildContext context) {
  return _shell('client', 'Harbor Club', filled: true);
}

Widget _twoCenters(BuildContext context) {
  return _frame(
    RoleShell(
      session: _previewSession([
        _row('client', 'harbor', 'Harbor Club'),
        _row('client', 'north', 'North Gym'),
      ]),
      preview: HomeCard.emptyFor('client', centerName: 'Harbor Club'),
    ),
  );
}

Widget _shell(
  String role,
  String center, {
  String branch = '',
  bool filled = false,
}) {
  final card = filled
      ? HomeCard(
          question: HomeCard.emptyFor(role).question,
          centerName: center,
          branchName: branch,
          emptyTitle: '',
          emptyMessage: '',
          primaryAction: HomeCard.emptyFor(role).primaryAction,
          sessions: const [
            HomeSession(
              time: '07:00',
              title: 'Maya Chen',
              status: SessionStatus.confirmed,
            ),
          ],
        )
      : HomeCard.emptyFor(role, centerName: center, branchName: branch);
  return _frame(
    RoleShell(
      session: _previewSession([_row(role, 'harbor', center, branch: branch)]),
      preview: card,
    ),
  );
}

Widget _frame(Widget child) {
  return MaterialApp(theme: AppTheme.dark(), home: child);
}

SessionController _previewSession(List<Membership> memberships) {
  final session = SessionController(
    api: _QuietApi(),
    tokens: MemoryTokenStore(),
  );
  session
    ..profile = Profile(
      id: 'user',
      email: 'maya@harbor.club',
      displayName: 'Maya',
      accountType: memberships.first.role,
      memberships: memberships,
    )
    ..gate = Gate.shell
    ..accessToken = 'access';
  return session;
}

Membership _row(String role, String id, String center, {String branch = ''}) {
  return Membership(
    role: role,
    status: 'active',
    fitnessCenterId: id,
    centerName: center,
    branchName: branch,
    branches: branch.isEmpty
        ? const []
        : [BranchName(id: 'downtown', name: branch)],
  );
}

class _QuietApi extends AuthApi {
  _QuietApi() : super(baseUrl: 'http://example.test');
}
