import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/secondary_button.dart';
import '../auth/auth_api.dart';
import '../auth/session_controller.dart';
import 'people_views.dart';

/// Loads the roster and opens the invite, assign, and confirm sheets.
class PeopleScreen extends StatefulWidget {
  const PeopleScreen({required this.session, this.embedded = false, super.key});

  final SessionController session;
  final bool embedded;

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  PeoplePage _page = const PeoplePage(people: [], invites: []);
  var _loading = true;
  String? _branchId;
  String? _notice;

  bool get _isCenter =>
      widget.session.profile?.activeMembership?.role == 'center_admin';

  @override
  void initState() {
    super.initState();
    final branches =
        widget.session.profile?.activeMembership?.branches ?? const [];
    if (!_isCenter && branches.isNotEmpty) _branchId = branches.first.id;
    _load();
  }

  Future<void> _load() async {
    final access = widget.session.accessToken;
    if (access == null) return;
    try {
      final page = await widget.session.api.people(
        accessToken: access,
        branchId: _isCenter ? null : _branchId,
      );
      if (mounted) {
        setState(() {
          _page = page;
          _loading = false;
          _notice = null;
        });
      }
    } on AuthException catch (err) {
      if (mounted) {
        setState(() {
          _loading = false;
          _notice = err.message;
        });
      }
    }
  }

  Future<void> _invite() async {
    final branches = _isCenter
        ? widget.session.profile?.activeMembership?.branches ??
              const <BranchName>[]
        : _selectedBranch();
    var code = '';
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoal,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return SizedBox(
              height: 560,
              child: InvitePersonSheet(
                branches: branches,
                code: code.isEmpty ? null : code,
                onInvite: (role, email, branchId) async {
                  final access = widget.session.accessToken;
                  if (access == null) return;
                  try {
                    final next = await widget.session.api.invitePerson(
                      accessToken: access,
                      email: email,
                      role: role,
                      branchId: branchId,
                      headerBranchId: _isCenter ? null : branchId,
                    );
                    setSheet(() => code = next);
                    await _load();
                  } on AuthException catch (err) {
                    if (mounted) setState(() => _notice = err.message);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  List<BranchName> _selectedBranch() {
    final branches =
        widget.session.profile?.activeMembership?.branches ?? const [];
    for (final branch in branches) {
      if (branch.id == _branchId) return [branch];
    }
    if (branches.isEmpty) return const [];
    return [branches.first];
  }

  Future<void> _open(PersonRow person) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.charcoal,
      builder: (context) {
        return SizedBox(
          height: 520,
          child: PersonSheet(
            person: person,
            onAssign: person.role == 'client' ? () => _assign(person) : null,
            onChangeBranches: _isCenter && person.role == 'manager'
                ? () => _branches(person)
                : null,
            onSuspend: () =>
                _confirm(person, suspend: person.status != 'suspended'),
            onRemove: () => _confirm(person, suspend: false, remove: true),
          ),
        );
      },
    );
  }

  Future<void> _assign(PersonRow client) async {
    final trainers = _page.people
        .where(
          (person) =>
              person.role == 'trainer' && person.branchId == client.branchId,
        )
        .toList();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.charcoal,
      builder: (context) {
        return AssignTrainerSheet(
          clientName: client.displayName,
          trainers: trainers,
          onAssign: (trainer) async {
            final access = widget.session.accessToken;
            if (access == null) return;
            await widget.session.api.assignTrainer(
              accessToken: access,
              clientUserId: client.userId,
              trainerUserId: trainer.userId,
              branchId: _isCenter ? null : client.branchId,
            );
            if (context.mounted) Navigator.of(context).pop();
            await _load();
          },
        );
      },
    );
  }

  Future<void> _branches(PersonRow person) async {
    final branches =
        widget.session.profile?.activeMembership?.branches ??
        const <BranchName>[];
    final selected = <String>{
      for (final row in _page.people)
        if (row.userId == person.userId && row.branchId.isNotEmpty)
          row.branchId,
    };
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.charcoal,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                for (final branch in branches)
                  CheckboxListTile(
                    value: selected.contains(branch.id),
                    title: Text(branch.name),
                    onChanged: (value) {
                      setSheet(() {
                        if (value ?? false) {
                          selected.add(branch.id);
                        } else {
                          selected.remove(branch.id);
                        }
                      });
                    },
                  ),
                SecondaryButton(
                  label: 'Save branches',
                  onPressed: () async {
                    final access = widget.session.accessToken;
                    if (access == null || selected.isEmpty) return;
                    await widget.session.api.replaceManagerBranches(
                      accessToken: access,
                      userId: person.userId,
                      branchIds: selected.toList(),
                    );
                    if (context.mounted) Navigator.of(context).pop();
                    await _load();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirm(
    PersonRow person, {
    required bool suspend,
    bool remove = false,
  }) async {
    final name = person.displayName;
    final title = remove
        ? 'Remove $name?'
        : suspend
        ? 'Suspend $name?'
        : 'Restore $name?';
    final message = remove
        ? 'Access stops. The center keeps the session records.'
        : suspend
        ? 'Access stops at this center.'
        : 'This center opens again.';
    final action = remove
        ? 'Remove'
        : suspend
        ? 'Suspend'
        : 'Restore';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.charcoal,
      builder: (context) {
        return SizedBox(
          height: 320,
          child: ConfirmActionSheet(
            title: title,
            message: message,
            action: action,
            onConfirm: () async {
              final access = widget.session.accessToken;
              if (access == null) return;
              final branchId = _isCenter ? null : person.branchId;
              if (remove) {
                await widget.session.api.removePerson(
                  accessToken: access,
                  userId: person.userId,
                  branchId: branchId,
                );
              } else if (suspend) {
                await widget.session.api.suspendPerson(
                  accessToken: access,
                  userId: person.userId,
                  branchId: branchId,
                );
              } else {
                await widget.session.api.restorePerson(
                  accessToken: access,
                  userId: person.userId,
                  branchId: branchId,
                );
              }
              if (context.mounted) Navigator.of(context).pop();
              await _load();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        if (!widget.embedded)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ),
        if (_notice != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _notice!,
              style: const TextStyle(color: AppColors.clay),
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: Text('Loading people'))
              : PeopleListView(
                  people: _page.people,
                  invites: _page.invites,
                  includeManagers: _isCenter,
                  onInvite: _invite,
                  onOpen: _open,
                ),
        ),
      ],
    );
    if (widget.embedded) return body;
    return Scaffold(body: SafeArea(child: body));
  }
}

class AcceptCodeScreen extends StatefulWidget {
  const AcceptCodeScreen({required this.session, super.key});

  final SessionController session;

  @override
  State<AcceptCodeScreen> createState() => _AcceptCodeScreenState();
}

class _AcceptCodeScreenState extends State<AcceptCodeScreen> {
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = await widget.session.acceptCode(_code.text.trim());
    if (mounted) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AcceptCodeForm(
          controller: _code,
          error: _error,
          onSubmit: _submit,
        ),
      ),
    );
  }
}
