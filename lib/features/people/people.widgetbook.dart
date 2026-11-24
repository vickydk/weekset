import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../core/theme/app_theme.dart';
import '../auth/auth_api.dart';
import 'people_views.dart';

WidgetbookFolder peopleFolder() {
  return WidgetbookFolder(
    name: 'People',
    children: [
      WidgetbookComponent(
        name: 'People list',
        useCases: [WidgetbookUseCase(name: 'branch roster', builder: _list)],
      ),
      WidgetbookComponent(
        name: 'Invite sheet',
        useCases: [WidgetbookUseCase(name: 'PT or client', builder: _invite)],
      ),
      WidgetbookComponent(
        name: 'Assign sheet',
        useCases: [
          WidgetbookUseCase(name: 'PTs at this branch', builder: _assign),
        ],
      ),
      WidgetbookComponent(
        name: 'Confirm suspend',
        useCases: [WidgetbookUseCase(name: 'access stops', builder: _suspend)],
      ),
      WidgetbookComponent(
        name: 'Confirm remove',
        useCases: [WidgetbookUseCase(name: 'records stay', builder: _remove)],
      ),
      WidgetbookComponent(
        name: 'Invalid code',
        useCases: [
          WidgetbookUseCase(name: 'invite is not valid', builder: _invalid),
        ],
      ),
    ],
  );
}

Widget _frame(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: SafeArea(child: child)),
  );
}

const _maya = PersonRow(
  userId: 'maya',
  displayName: 'Maya Chen',
  email: 'maya@harbor.club',
  role: 'client',
  status: 'active',
  branchId: 'downtown',
  branchName: 'Downtown',
  trainerName: '',
);

const _alex = PersonRow(
  userId: 'alex',
  displayName: 'Alex Rivera',
  email: 'alex@harbor.club',
  role: 'trainer',
  status: 'active',
  branchId: 'downtown',
  branchName: 'Downtown',
  trainerName: '',
);

Widget _list(BuildContext context) {
  return _frame(
    PeopleListView(
      includeManagers: false,
      onInvite: () {},
      onOpen: (_) {},
      people: const [_alex, _maya],
      invites: const [
        OpenInvite(
          email: 'sam@harbor.club',
          role: 'client',
          branchName: 'Downtown',
        ),
      ],
    ),
  );
}

Widget _invite(BuildContext context) {
  return _frame(
    InvitePersonSheet(
      branches: const [BranchName(id: 'downtown', name: 'Downtown')],
      onInvite: (role, email, branchId) {},
    ),
  );
}

Widget _assign(BuildContext context) {
  return _frame(
    AssignTrainerSheet(
      clientName: 'Maya Chen',
      trainers: const [_alex],
      onAssign: (_) {},
    ),
  );
}

Widget _suspend(BuildContext context) {
  return _frame(
    ConfirmActionSheet(
      title: 'Suspend Maya Chen?',
      message: 'Access stops at this center.',
      action: 'Suspend',
      onConfirm: () {},
    ),
  );
}

Widget _remove(BuildContext context) {
  return _frame(
    ConfirmActionSheet(
      title: 'Remove Maya Chen?',
      message: 'Access stops. The center keeps the session records.',
      action: 'Remove',
      onConfirm: () {},
    ),
  );
}

Widget _invalid(BuildContext context) {
  return _frame(AcceptCodeForm(error: 'invite is not valid', onSubmit: () {}));
}
