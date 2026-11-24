import 'package:flutter/material.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_tab_bar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/context_header.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/option_switcher.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../auth/auth_api.dart';
import '../auth/session_controller.dart';
import '../home/home_card.dart';
import '../people/people_screen.dart';
import '../schedule/availability_screen.dart';
import '../schedule/availability_week.dart';
import '../schedule/client_week.dart';
import '../schedule/client_week_screen.dart';

/// One shell for the active role. Another role's path is sent home first.
class RoleShell extends StatefulWidget {
  const RoleShell({
    required this.session,
    this.initialPath,
    this.preview,
    super.key,
  });

  final SessionController session;
  final String? initialPath;
  final HomeCard? preview;

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  late String _path;
  HomeCard? _card;
  final _branch = TextEditingController();
  final _inviteEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    final role = widget.session.profile?.activeMembership?.role;
    _path = AppRouter.coerce(
      role,
      widget.initialPath ?? AppRouter.homeFor(role),
    );
    _card = widget.preview;
    if (widget.preview == null) _load();
  }

  @override
  void dispose() {
    _branch.dispose();
    _inviteEmail.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final access = widget.session.accessToken;
    final membership = _membership;
    if (access == null || membership == null) return;
    try {
      final card = await widget.session.api.home(
        accessToken: access,
        centerId: membership.fitnessCenterId,
        branchId: membership.role == 'manager' ? _branchId(membership) : null,
      );
      if (mounted) setState(() => _card = card);
    } on AuthException {
      if (mounted) {
        setState(
          () => _card = HomeCard.emptyFor(
            membership.role,
            centerName: membership.centerName,
          ),
        );
      }
    }
  }

  Membership? get _membership {
    final profile = widget.session.profile;
    if (profile == null) return null;
    final selected = widget.session.selectedCenterId;
    if (selected != null) {
      for (final row in profile.memberships) {
        if (row.fitnessCenterId == selected && row.status == 'active') {
          return row;
        }
      }
    }
    return profile.activeMembership;
  }

  String? _branchId(Membership membership) {
    final selected = widget.session.selectedBranchId;
    if (selected != null) return selected;
    if (membership.branches.isNotEmpty) return membership.branches.first.id;
    return null;
  }

  void _select(String path) {
    final role = _membership?.role;
    setState(() => _path = AppRouter.coerce(role, path));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.session,
      builder: (context, _) {
        final membership = _membership;
        final role = membership?.role;
        final path = AppRouter.coerce(role, _path);
        final tabs = _tabs(role);
        final index = tabs.indexWhere((tab) => tab.path == path);
        final selected = index < 0 ? 0 : index;
        final branches = membership?.branches ?? const <BranchName>[];
        final branch = role == 'trainer' || role == 'manager'
            ? (membership?.branchName ??
                  (branches.isEmpty ? null : branches.first.name))
            : null;
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: ContextHeader(
                    centerName: membership?.centerName ?? '',
                    branchName: branch,
                  ),
                ),
                Expanded(child: _body(path, membership)),
                AppTabBar(
                  items: [
                    for (final tab in tabs)
                      AppTab(label: tab.label, icon: tab.icon),
                  ],
                  selectedIndex: selected,
                  onSelected: (next) => _select(tabs[next].path),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(String path, Membership? membership) {
    final card =
        _card ??
        HomeCard.emptyFor(
          membership?.role,
          centerName: membership?.centerName ?? '',
        );
    return switch (path) {
      AppRouter.clientHome ||
      AppRouter.trainerToday ||
      AppRouter.managerToday ||
      AppRouter.centerToday => HomeDashboard(
        card: card,
        onPrimary: () => _select(_actionPath(membership?.role)),
      ),
      AppRouter.managerPeople || AppRouter.centerPeople => PeopleScreen(
        session: widget.session,
        embedded: true,
      ),
      AppRouter.centerBranches => _branches(membership),
      AppRouter.managerBranch => _managerBranches(membership),
      AppRouter.trainerAvailability =>
        widget.preview != null
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: AvailabilityWeek(hours: []),
              )
            : AvailabilityScreen(session: widget.session),
      AppRouter.clientSchedule =>
        widget.preview != null
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: ClientWeek(open: [], bookings: []),
              )
            : ClientWeekScreen(session: widget.session),
      AppRouter.clientProfile ||
      AppRouter.trainerProfile ||
      AppRouter.centerProfile => _profile(membership),
      _ => const EmptyState(
        title: 'Nothing here yet',
        message: 'This part of the week arrives with its own ticket.',
      ),
    };
  }

  String _actionPath(String? role) {
    return switch (role) {
      'manager' => AppRouter.managerPeople,
      'center_admin' => AppRouter.centerPeople,
      'trainer' => AppRouter.trainerAvailability,
      _ => AppRouter.clientSchedule,
    };
  }

  Widget _branches(Membership? membership) {
    final branches = membership?.branches ?? const <BranchName>[];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        for (final branch in branches)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              branch.name,
              style: const TextStyle(color: AppColors.paper, fontSize: 16),
            ),
          ),
        AppTextField(label: 'New branch', hint: 'Kemang', controller: _branch),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Add branch',
          onPressed: () => widget.session.addBranch(_branch.text),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Manager email',
          hint: 'lee@harbor.club',
          controller: _inviteEmail,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Invite manager',
          onPressed: () {
            widget.session.inviteManager(
              _inviteEmail.text,
              branches.map((branch) => branch.id).toList(),
            );
          },
        ),
        if (widget.session.inviteCode != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Code ${widget.session.inviteCode}',
              style: const TextStyle(
                color: AppColors.lime,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _managerBranches(Membership? membership) {
    final branches = membership?.branches ?? const <BranchName>[];
    if (branches.length < 2) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          branches.isEmpty
              ? 'This center has one branch.'
              : branches.first.name,
          style: const TextStyle(color: AppColors.paper, fontSize: 16),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: BranchSwitcher(
        selectedId: widget.session.selectedBranchId ?? branches.first.id,
        onSelected: (id) {
          widget.session.selectBranch(id);
          _load();
        },
        branches: [
          for (final branch in branches)
            SwitcherOption(id: branch.id, title: branch.name),
        ],
      ),
    );
  }

  Widget _profile(Membership? membership) {
    final centers =
        widget.session.profile?.memberships
            .where((row) => row.role == 'client' && row.status == 'active')
            .toList() ??
        const <Membership>[];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (membership?.role == 'trainer')
          Text(
            membership?.branchName ?? '',
            style: const TextStyle(color: AppColors.paper, fontSize: 16),
          ),
        if (membership?.role == 'client' && centers.length > 1)
          CenterSwitcher(
            selectedId: membership?.fitnessCenterId ?? '',
            onSelected: (id) {
              widget.session.selectCenter(id);
              _load();
            },
            centers: [
              for (final row in centers)
                SwitcherOption(id: row.fitnessCenterId, title: row.centerName),
            ],
          ),
        const EmptyState(
          title: 'No updates',
          message: 'Notifications stay in the app.',
        ),
        const SizedBox(height: 16),
        SecondaryButton(label: 'Sign out', onPressed: widget.session.signOut),
      ],
    );
  }
}

class _ShellTab {
  const _ShellTab(this.label, this.icon, this.path);
  final String label;
  final IconData icon;
  final String path;
}

List<_ShellTab> _tabs(String? role) {
  return switch (role) {
    'trainer' => const [
      _ShellTab('Today', Icons.today, AppRouter.trainerToday),
      _ShellTab('Availability', Icons.schedule, AppRouter.trainerAvailability),
      _ShellTab('Clients', Icons.people, AppRouter.trainerClients),
      _ShellTab('Profile', Icons.person, AppRouter.trainerProfile),
    ],
    'manager' => const [
      _ShellTab('Today', Icons.today, AppRouter.managerToday),
      _ShellTab('People', Icons.people, AppRouter.managerPeople),
      _ShellTab('Schedule', Icons.calendar_month, AppRouter.managerSchedule),
      _ShellTab('Branch', Icons.store, AppRouter.managerBranch),
    ],
    'center_admin' => const [
      _ShellTab('Today', Icons.today, AppRouter.centerToday),
      _ShellTab('Branches', Icons.store, AppRouter.centerBranches),
      _ShellTab('People', Icons.people, AppRouter.centerPeople),
      _ShellTab('Center', Icons.apartment, AppRouter.centerProfile),
    ],
    _ => const [
      _ShellTab('Home', Icons.home, AppRouter.clientHome),
      _ShellTab('Schedule', Icons.calendar_month, AppRouter.clientSchedule),
      _ShellTab('History', Icons.history, AppRouter.clientHistory),
      _ShellTab('Profile', Icons.person, AppRouter.clientProfile),
    ],
  };
}
