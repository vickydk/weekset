import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekset/app.dart';
import 'package:weekset/core/theme/app_theme.dart';
import 'package:weekset/core/widgets/locked_screen.dart';
import 'package:weekset/core/widgets/option_switcher.dart';
import 'package:weekset/core/widgets/status_chip.dart';
import 'package:weekset/core/widgets/suspended_screen.dart';
import 'package:weekset/features/auth/auth_api.dart';
import 'package:weekset/features/auth/auth_gate.dart';
import 'package:weekset/features/auth/token_store.dart';
import 'package:weekset/features/people/people_views.dart';

void main() {
  testWidgets('opens on the welcome screen', (tester) async {
    await tester.pumpWidget(
      WeeksetApp(api: _FakeApi(), tokens: MemoryTokenStore()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your week, with your trainer.'), findsOneWidget);
  });

  testWidgets('register with empty memberships does not build a shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      WeeksetApp(api: _FakeApi(), tokens: MemoryTokenStore()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Client'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Maya Chen'), 'Maya');
    await tester.enterText(
      find.widgetWithText(TextField, 'maya@harbor.club').at(0),
      'maya@harbor.club',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'At least 8 characters'),
      'long-enough',
    );
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();

    expect(find.byType(LockedScreen), findsOneWidget);
    expect(find.byType(RoleShell), findsNothing);
    expect(find.text('I have a code'), findsOneWidget);

    await tester.tap(find.text('I have a code'));
    await tester.pumpAndSettle();
    expect(find.text('Join with code'), findsOneWidget);
  });

  testWidgets('a 390-wide locked frame stays inside the safe area', (
    tester,
  ) async {
    await _pumpPhone(tester, LockedScreen(onHaveCode: () {}, onSignOut: () {}));
    expect(find.text('I have a code'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('suspended names the center and the other-center action', (
    tester,
  ) async {
    await _pumpPhone(
      tester,
      SuspendedScreen(
        centerName: 'Harbor Club',
        onSignOut: () {},
        onOpenOtherCenter: () {},
      ),
    );
    expect(find.text('Membership paused'), findsOneWidget);
    expect(find.text('Open my other center'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('status chips keep a label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Wrap(
            children: [
              StatusChip(status: SessionStatus.requested),
              StatusChip(status: SessionStatus.confirmed),
              StatusChip(status: SessionStatus.declined),
              StatusChip(status: SessionStatus.cancelled),
              StatusChip(status: SessionStatus.completed),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Requested'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Declined'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('the current center is labeled, not only colored', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: CenterSwitcher(
            selectedId: 'harbor',
            onSelected: (_) {},
            centers: const [
              SwitcherOption(id: 'harbor', title: 'Harbor Club'),
              SwitcherOption(id: 'north', title: 'North Gym'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Current'), findsOneWidget);
  });

  testWidgets('a wrong password shows the same login error', (tester) async {
    final api = _FakeApi()..failLogin = true;
    await tester.pumpWidget(WeeksetApp(api: api, tokens: MemoryTokenStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with email'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'maya@harbor.club'),
      'maya@harbor.club',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'nope-nope',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    expect(find.text('That email or password is not right.'), findsOneWidget);
    expect(find.byType(RoleShell), findsNothing);
  });

  testWidgets('people list names a client without a PT', (tester) async {
    await _pumpPhone(
      tester,
      PeopleListView(
        includeManagers: true,
        onInvite: () {},
        onOpen: (_) {},
        people: const [
          PersonRow(
            userId: 'maya',
            displayName: 'Maya Chen',
            email: 'maya@harbor.club',
            role: 'client',
            status: 'active',
            branchId: 'downtown',
            branchName: 'Downtown',
            trainerName: '',
          ),
        ],
        invites: const [],
      ),
    );
    expect(find.text('PT not assigned.'), findsOneWidget);
    expect(find.text('Clients'), findsOneWidget);
  });

  testWidgets('an invalid code is shown on the join form', (tester) async {
    await _pumpPhone(
      tester,
      Scaffold(
        body: AcceptCodeForm(error: 'invite is not valid', onSubmit: () {}),
      ),
    );
    expect(find.text('invite is not valid'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpPhone(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.dark(), home: child));
}

class _FakeApi extends AuthApi {
  _FakeApi() : super(baseUrl: 'http://example.test');

  bool failLogin = false;

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
    required String accountType,
  }) async {
    return AuthSession(
      accessToken: 'access',
      refreshToken: 'refresh',
      profile: Profile(
        id: 'user',
        email: email,
        displayName: displayName,
        accountType: accountType,
        memberships: const [],
      ),
    );
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (failLogin) {
      throw const AuthException('That email or password is not right.');
    }
    return AuthSession(
      accessToken: 'access',
      refreshToken: 'refresh',
      profile: Profile(
        id: 'user',
        email: email,
        displayName: 'Maya',
        accountType: 'client',
        memberships: const [],
      ),
    );
  }
}
