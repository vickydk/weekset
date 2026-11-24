import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_tab_bar.dart';
import 'app_text_field.dart';
import 'context_header.dart';
import 'empty_state.dart';
import 'locked_screen.dart';
import 'option_switcher.dart';
import 'primary_button.dart';
import 'secondary_button.dart';
import 'session_card.dart';
import 'status_chip.dart';
import 'suspended_screen.dart';
import 'week_mark.dart';

WidgetbookFolder foundationsFolder() {
  return WidgetbookFolder(
    name: 'Foundations',
    children: [
      WidgetbookComponent(
        name: 'Primary button',
        useCases: [WidgetbookUseCase(name: 'default', builder: _primary)],
      ),
      WidgetbookComponent(
        name: 'Secondary button',
        useCases: [WidgetbookUseCase(name: 'default', builder: _secondary)],
      ),
      WidgetbookComponent(
        name: 'Text field',
        useCases: [WidgetbookUseCase(name: 'email', builder: _field)],
      ),
      WidgetbookComponent(
        name: 'Status chip',
        useCases: [WidgetbookUseCase(name: 'all', builder: _chips)],
      ),
      WidgetbookComponent(
        name: 'Session card',
        useCases: [WidgetbookUseCase(name: 'confirmed', builder: _card)],
      ),
      WidgetbookComponent(
        name: 'Tab bar',
        useCases: [WidgetbookUseCase(name: 'today', builder: _tabs)],
      ),
      WidgetbookComponent(
        name: 'Context header',
        useCases: [WidgetbookUseCase(name: 'branch', builder: _header)],
      ),
      WidgetbookComponent(
        name: 'Center switcher',
        useCases: [WidgetbookUseCase(name: 'two centers', builder: _centers)],
      ),
      WidgetbookComponent(
        name: 'Branch switcher',
        useCases: [WidgetbookUseCase(name: 'two branches', builder: _branches)],
      ),
      WidgetbookComponent(
        name: 'Empty states',
        useCases: [
          WidgetbookUseCase(name: 'week, history, solo', builder: _empty),
        ],
      ),
      WidgetbookComponent(
        name: 'Locked screen',
        useCases: [WidgetbookUseCase(name: 'default', builder: _locked)],
      ),
      WidgetbookComponent(
        name: 'Suspended screen',
        useCases: [
          WidgetbookUseCase(name: 'other center', builder: _suspended),
        ],
      ),
      WidgetbookComponent(
        name: 'Week mark',
        useCases: [WidgetbookUseCase(name: 'icon', builder: _mark)],
      ),
    ],
  );
}

Widget _phone(Widget child) {
  return Theme(
    data: AppTheme.dark(),
    child: ColoredBox(
      color: AppColors.charcoal,
      child: Center(child: SizedBox(width: 390, height: 844, child: child)),
    ),
  );
}

Widget _pad(Widget child) {
  return _phone(Padding(padding: const EdgeInsets.all(24), child: child));
}

Widget _primary(BuildContext context) {
  return _pad(PrimaryButton(label: 'Request this hour', onPressed: () {}));
}

Widget _secondary(BuildContext context) {
  return _pad(SecondaryButton(label: 'Sign out', onPressed: () {}));
}

Widget _field(BuildContext context) {
  return _pad(const AppTextField(label: 'Email', hint: 'maya@harbor.club'));
}

Widget _chips(BuildContext context) {
  return _pad(
    const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        StatusChip(status: SessionStatus.requested),
        StatusChip(status: SessionStatus.confirmed),
        StatusChip(status: SessionStatus.declined),
        StatusChip(status: SessionStatus.cancelled),
        StatusChip(status: SessionStatus.completed),
      ],
    ),
  );
}

Widget _card(BuildContext context) {
  return _pad(
    const SessionCard(
      time: '07:00–08:00',
      title: 'Alex · Maya',
      status: SessionStatus.confirmed,
    ),
  );
}

Widget _tabs(BuildContext context) {
  return _phone(
    Column(
      children: [
        const Spacer(),
        AppTabBar(
          selectedIndex: 0,
          onSelected: (_) {},
          items: const [
            AppTab(label: 'Today', icon: Icons.home_outlined),
            AppTab(label: 'Week', icon: Icons.calendar_today_outlined),
            AppTab(label: 'History', icon: Icons.history),
            AppTab(label: 'Profile', icon: Icons.person_outline),
          ],
        ),
      ],
    ),
  );
}

Widget _header(BuildContext context) {
  return _pad(
    const ContextHeader(centerName: 'Harbor Club', branchName: 'Downtown'),
  );
}

Widget _centers(BuildContext context) {
  return _pad(
    CenterSwitcher(
      selectedId: 'harbor',
      onSelected: (_) {},
      centers: const [
        SwitcherOption(
          id: 'harbor',
          title: 'Harbor Club',
          subtitle: 'Downtown',
        ),
        SwitcherOption(id: 'north', title: 'North Gym', subtitle: 'Kemang'),
      ],
    ),
  );
}

Widget _branches(BuildContext context) {
  return _pad(
    BranchSwitcher(
      selectedId: 'downtown',
      onSelected: (_) {},
      branches: const [
        SwitcherOption(id: 'downtown', title: 'Downtown'),
        SwitcherOption(id: 'kemang', title: 'Kemang'),
      ],
    ),
  );
}

Widget _empty(BuildContext context) {
  return _pad(
    const Column(
      children: [
        EmptyState(title: 'Empty week', message: 'One open hour'),
        SizedBox(height: 12),
        EmptyState(title: 'No sessions yet', message: 'History is empty'),
        SizedBox(height: 12),
        EmptyState(title: 'No solo plan', message: 'Ask the trainer'),
      ],
    ),
  );
}

Widget _locked(BuildContext context) {
  return _phone(LockedScreen(onHaveCode: () {}, onSignOut: () {}));
}

Widget _suspended(BuildContext context) {
  return _phone(
    SuspendedScreen(
      centerName: 'Harbor Club',
      onSignOut: () {},
      onOpenOtherCenter: () {},
    ),
  );
}

Widget _mark(BuildContext context) {
  return _phone(const Center(child: WeekMark(size: 160)));
}
