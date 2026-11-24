import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../auth/auth_api.dart';

String roleLabel(String role) {
  return switch (role) {
    'trainer' => 'PT',
    'manager' => 'Manager',
    'client' => 'Client',
    _ => role,
  };
}

/// The roster, grouped the way the caller is allowed to see it.
class PeopleListView extends StatelessWidget {
  const PeopleListView({
    required this.people,
    required this.invites,
    required this.includeManagers,
    required this.onInvite,
    required this.onOpen,
    super.key,
  });

  final List<PersonRow> people;
  final List<OpenInvite> invites;
  final bool includeManagers;
  final VoidCallback onInvite;
  final ValueChanged<PersonRow> onOpen;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<PersonRow>>{
      if (includeManagers) 'Managers': _withRole('manager'),
      'PTs': _withRole('trainer'),
      'Clients': _withRole('client'),
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        const Text(
          'People',
          style: TextStyle(
            color: AppColors.paper,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Invite', onPressed: onInvite),
        const SizedBox(height: 24),
        if (people.isEmpty && invites.isEmpty)
          const EmptyState(
            title: 'No one here yet',
            message: 'Invite a PT or a client. The code works once.',
          ),
        for (final entry in groups.entries) ...[
          if (entry.value.isNotEmpty) ...[
            Text(
              entry.key,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            for (final person in entry.value)
              _PersonTile(person: person, onOpen: () => onOpen(person)),
            const SizedBox(height: 16),
          ],
        ],
        if (invites.isNotEmpty) ...[
          const Text(
            'Waiting',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          for (final invite in invites)
            _Card(
              title: invite.email,
              detail: '${roleLabel(invite.role)} · ${invite.branchName}',
            ),
        ],
      ],
    );
  }

  List<PersonRow> _withRole(String role) {
    return people.where((person) => person.role == role).toList();
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person, required this.onOpen});

  final PersonRow person;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final detail = person.role == 'client'
        ? (person.trainerName.isEmpty ? 'PT not assigned.' : person.trainerName)
        : '${roleLabel(person.role)} · ${person.branchName}';
    return _Card(title: person.displayName, detail: detail, onTap: onOpen);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.detail, this.onTap});

  final String title;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Name, email, and the actions that are allowed for this person.
class PersonSheet extends StatelessWidget {
  const PersonSheet({
    required this.person,
    required this.onAssign,
    required this.onSuspend,
    required this.onRemove,
    this.onChangeBranches,
    super.key,
  });

  final PersonRow person;
  final VoidCallback? onAssign;
  final VoidCallback onSuspend;
  final VoidCallback onRemove;
  final VoidCallback? onChangeBranches;

  @override
  Widget build(BuildContext context) {
    final suspended = person.status == 'suspended';
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        Text(
          person.displayName,
          style: const TextStyle(
            color: AppColors.paper,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          person.email,
          style: const TextStyle(color: AppColors.muted, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Text(
          '${roleLabel(person.role)} · ${person.branchName}',
          style: const TextStyle(color: AppColors.paper, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          suspended ? 'Suspended' : 'Active',
          style: const TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        if (person.role == 'client') ...[
          const SizedBox(height: 8),
          Text(
            person.trainerName.isEmpty
                ? 'PT not assigned.'
                : person.trainerName,
            style: const TextStyle(color: AppColors.paper, fontSize: 16),
          ),
        ],
        const SizedBox(height: 24),
        if (onAssign != null)
          SecondaryButton(label: 'Assign PT', onPressed: onAssign),
        if (onChangeBranches != null)
          SecondaryButton(
            label: 'Change branches',
            onPressed: onChangeBranches,
          ),
        ClayButton(
          label: suspended ? 'Restore' : 'Suspend',
          onPressed: onSuspend,
        ),
        ClayButton(label: 'Remove', onPressed: onRemove),
      ],
    );
  }
}

class InvitePersonSheet extends StatefulWidget {
  const InvitePersonSheet({
    required this.branches,
    required this.onInvite,
    this.code,
    super.key,
  });

  final List<BranchName> branches;
  final void Function(String role, String email, String branchId) onInvite;
  final String? code;

  @override
  State<InvitePersonSheet> createState() => _InvitePersonSheetState();
}

class _InvitePersonSheetState extends State<InvitePersonSheet> {
  final _email = TextEditingController();
  var _role = 'trainer';
  String? _branchId;

  @override
  void initState() {
    super.initState();
    _branchId = widget.branches.length == 1 ? widget.branches.first.id : null;
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        const Text(
          'Invite',
          style: TextStyle(
            color: AppColors.paper,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'They already have an account. The code works once, for seven days.',
          style: TextStyle(color: AppColors.muted, fontSize: 16),
        ),
        const SizedBox(height: 16),
        _Choice(
          label: 'PT',
          selected: _role == 'trainer',
          onTap: () => setState(() => _role = 'trainer'),
        ),
        _Choice(
          label: 'Client',
          selected: _role == 'client',
          onTap: () => setState(() => _role = 'client'),
        ),
        if (widget.branches.length > 1)
          for (final branch in widget.branches)
            _Choice(
              label: branch.name,
              selected: _branchId == branch.id,
              onTap: () => setState(() => _branchId = branch.id),
            ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Email',
          hint: 'maya@harbor.club',
          controller: _email,
        ),
        if (widget.code != null) ...[
          const SizedBox(height: 12),
          Text(
            'Code ${widget.code}',
            style: const TextStyle(
              color: AppColors.lime,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Send code',
          onPressed: _branchId == null
              ? null
              : () => widget.onInvite(_role, _email.text, _branchId!),
        ),
      ],
    );
  }
}

class AssignTrainerSheet extends StatelessWidget {
  const AssignTrainerSheet({
    required this.clientName,
    required this.trainers,
    required this.onAssign,
    super.key,
  });

  final String clientName;
  final List<PersonRow> trainers;
  final ValueChanged<PersonRow> onAssign;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        Text(
          'Assign a PT for $clientName',
          style: const TextStyle(
            color: AppColors.paper,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (trainers.isEmpty)
          const EmptyState(
            title: 'No PT at this branch',
            message: 'Invite a PT before assigning one.',
          ),
        for (final trainer in trainers)
          _Card(
            title: trainer.displayName,
            detail: trainer.branchName,
            onTap: () => onAssign(trainer),
          ),
      ],
    );
  }
}

class ConfirmActionSheet extends StatelessWidget {
  const ConfirmActionSheet({
    required this.title,
    required this.message,
    required this.action,
    required this.onConfirm,
    super.key,
  });

  final String title;
  final String message;
  final String action;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.paper,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const Spacer(),
          ClayButton(label: action, onPressed: onConfirm),
        ],
      ),
    );
  }
}

class AcceptCodeForm extends StatelessWidget {
  const AcceptCodeForm({
    required this.onSubmit,
    this.controller,
    this.error,
    super.key,
  });

  final VoidCallback onSubmit;
  final TextEditingController? controller;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        const Text(
          'Join with code',
          style: TextStyle(
            color: AppColors.paper,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'The code is for this account. It opens one center.',
          style: TextStyle(color: AppColors.muted, fontSize: 16),
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Code',
          hint: 'Paste the code',
          controller: controller,
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(
            error!,
            style: const TextStyle(color: AppColors.clay, fontSize: 16),
          ),
        ],
        const SizedBox(height: 24),
        PrimaryButton(label: 'Join', onPressed: onSubmit),
      ],
    );
  }
}

class ClayButton extends StatelessWidget {
  const ClayButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.actionHeight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.clay,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(
                color: selected ? AppColors.lime : AppColors.line,
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(color: AppColors.paper, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
