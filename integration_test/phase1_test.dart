import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:weekset/app.dart';

const _password = 'weekset1';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('phase 1 week on this device', (tester) async {
    final failed = <String>[];

    Future<void> settle([int frames = 8]) async {
      for (var i = 0; i < frames; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    Future<bool> appears(Finder finder, {int seconds = 20}) async {
      final end = DateTime.now().add(Duration(seconds: seconds));
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 200));
        if (finder.evaluate().isNotEmpty) return true;
      }
      return false;
    }

    void check(String name, bool ok) {
      // ignore: avoid_print
      print(ok ? 'PASS $name' : 'FAIL $name');
      if (!ok) failed.add(name);
    }

    bool signedOut() =>
        find.text('Continue with email').evaluate().isNotEmpty ||
        find.text('Log in').evaluate().isNotEmpty;

    Future<void> reachSignedOut() async {
      await tester.pumpWidget(const WeeksetApp());
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 250));
        if (signedOut()) return;
        if (find.text('Sign out').evaluate().isNotEmpty) {
          await tester.ensureVisible(find.text('Sign out').first);
          await tester.tap(find.text('Sign out').first);
          await tester.pump();
          continue;
        }
        for (final tab in ['Profile', 'Center', 'Branch']) {
          final finder = find.text(tab);
          if (finder.evaluate().isNotEmpty) {
            await tester.tap(finder.last);
            await tester.pump(const Duration(milliseconds: 300));
            break;
          }
        }
      }
    }

    Future<void> login(String email) async {
      await reachSignedOut();
      if (find.text('Continue with email').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue with email'));
        await settle(3);
      }
      await tester.enterText(find.byType(TextField).at(0), email);
      await tester.enterText(find.byType(TextField).at(1), _password);
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pump();
    }

    Future<void> openTab(String label) async {
      final tab = find.text(label);
      expect(tab, findsWidgets);
      await tester.tap(tab.last);
      await settle(6);
    }

    bool seen(String text) =>
        find.text(text, skipOffstage: false).evaluate().isNotEmpty;

    Future<bool> reveal(String text, {bool contains = false}) async {
      final finder = contains ? find.textContaining(text) : find.text(text);
      for (var i = 0; i < 40; i++) {
        if (finder.evaluate().isNotEmpty) return true;
        final lists = find.byType(Scrollable);
        if (lists.evaluate().isEmpty) return false;
        await tester.drag(lists.last, const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 50));
      }
      return finder.evaluate().isNotEmpty;
    }

    bool contains(String text) =>
        find.textContaining(text).evaluate().isNotEmpty;

    Future<void> signOut() async {
      if (find.text('Sign out').evaluate().isEmpty) {
        for (final tab in ['Profile', 'Center', 'Branch']) {
          final finder = find.text(tab);
          if (finder.evaluate().isNotEmpty) {
            await tester.tap(finder.last);
            await settle(4);
            break;
          }
        }
      }
      final button = find.text('Sign out');
      if (button.evaluate().isEmpty) return;
      await tester.ensureVisible(button.first);
      await tester.tap(button.first);
      await tester.pump();
    }

    await login('maya.weekset.accept@gmail.com');
    check(
      'client lands on Home',
      await appears(find.text('What do I do next?')),
    );
    check(
      'client home shows the solo plan',
      await appears(find.text('squat')) && seen('1 movements'),
    );
    check(
      'client home shows the finished hour',
      await appears(find.text('Completed')) && seen('07:00'),
    );

    await tester.pumpWidget(const WeeksetApp());
    check(
      'client session restores into the same shell',
      await appears(find.text('What do I do next?')) && seen('squat'),
    );

    await openTab('Schedule');
    check(
      'client schedule shows an open hour',
      await appears(find.text('Open')),
    );
    check(
      'client schedule shows the skipped date and the following week',
      await reveal('Cancelled') && await reveal('Requested'),
    );
    check(
      'client can skip one date of the pattern',
      await reveal('Skip', contains: true),
    );

    await openTab('History');
    check(
      'client history lists the finished hour',
      await appears(find.byType(ListTile)),
    );
    if (find.byType(ListTile).evaluate().isNotEmpty) {
      await tester.ensureVisible(find.byType(ListTile).first);
      await tester.tap(find.byType(ListTile).first);
      await settle(8);
    }
    check(
      'client reads the note, sets, reps, and load',
      await appears(find.text('felt stronger')) && seen('squat  5 × 42 kg'),
    );
    check(
      'client history has no edit control',
      find.text('Save log').evaluate().isEmpty &&
          find.byType(TextField).evaluate().isEmpty,
    );

    await openTab('Profile');
    check(
      'client sees the confirmation notice',
      await appears(find.text('Hour confirmed')),
    );
    if (seen('Hour confirmed')) {
      await tester.ensureVisible(find.text('Hour confirmed').first);
      await tester.tap(find.text('Hour confirmed').first);
      await settle(8);
    }
    check(
      'opening the notice lands on the schedule',
      await appears(find.text('Open')) || seen('Repeat for 8 weeks'),
    );

    await openTab('Profile');
    check('client can switch fitness center', seen('North'));
    if (seen('North')) {
      await tester.tap(find.text('North'));
      await settle(8);
      await openTab('Home');
    }
    check(
      'the other center has a different week',
      seen('No session today') && !seen('squat') && !seen('felt stronger'),
    );

    await openTab('Profile');
    await signOut();
    check('client can sign out', await appears(find.text('Log in')));

    await login('nia.weekset.accept@gmail.com');
    check(
      'an uninvited person stays on the locked screen',
      await appears(find.text('Account ready')),
    );
    await signOut();
    await appears(find.text('Log in'));

    await login('sam.weekset.accept@gmail.com');
    check(
      'suspended client opens the other center',
      await appears(find.text('What do I do next?')),
    );
    await openTab('Profile');
    check(
      'the suspended center is not offered',
      seen('North') && !seen('Harbor'),
    );
    await signOut();
    await appears(find.text('Log in'));

    await login('alex.weekset.accept@gmail.com');
    check('PT lands on Today', await appears(find.text('Who needs me today?')));
    check(
      'PT sees the finished hour',
      await appears(find.text('Completed')) || seen('Write the log'),
    );
    await openTab('Availability');
    check('PT week shows open hours', await appears(find.text('Open')));
    check('PT week shows the closed hour', await reveal('Closed'));
    await openTab('Clients');
    check('PT sees the movement library', await appears(find.text('squat')));
    if (seen('squat')) {
      await tester.tap(find.text('squat').first);
      await settle(4);
    }
    check('the movement plays as a silent loop', seen('Silent loop'));
    check(
      'PT can assign that movement as a solo day',
      find.textContaining('Assign solo day to').evaluate().isNotEmpty,
    );
    await openTab('Profile');
    await signOut();
    await appears(find.text('Log in'));

    await login('riley.weekset.accept@gmail.com');
    check(
      'second-branch PT lands on Today',
      await appears(find.text('Who needs me today?')),
    );
    await openTab('Clients');
    await settle(8);
    check(
      'second-branch PT does not see Downtown clients',
      !seen('Maya Chen') && !seen('Sam Ortiz'),
    );
    await openTab('Profile');
    await signOut();
    await appears(find.text('Log in'));

    await login('morgan.weekset.accept@gmail.com');
    check(
      'manager lands in the manager shell',
      await appears(find.text('What is stuck at this branch?')),
    );
    await openTab('People');
    check(
      'manager sees the roster',
      await appears(find.textContaining('Maya Chen')) && contains('Alex PT'),
    );
    await openTab('Schedule');
    check(
      'manager sees who trains downtown',
      await appears(find.textContaining('Maya Chen')),
    );
    check(
      'manager timetable has no note or load',
      !contains('felt stronger') && !contains('42 kg'),
    );
    await openTab('Branch');
    check('manager can switch branch', seen('Uptown'));
    if (seen('Uptown')) {
      await tester.tap(find.text('Uptown'));
      await settle(4);
    }
    await openTab('Schedule');
    check(
      'the second branch has a different timetable',
      await appears(find.text('No one is booked')),
    );
    await openTab('Branch');
    await signOut();
    check(
      'manager can sign out',
      await appears(find.text('Log in')),
    );

    await login('ada.weekset.accept@gmail.com');
    check(
      'fitness center lands in the center shell',
      await appears(find.text('Which branch needs an owner?')),
    );
    await openTab('People');
    check(
      'center people shows managers, PTs, and clients',
      await appears(find.text('Managers')) &&
          seen('PTs') &&
          seen('Clients') &&
          seen('Maya Chen'),
    );
    check(
      'center people has no workout fields',
      !contains('felt stronger') && !contains('42 kg'),
    );
    await openTab('Today');
    check(
      'center schedule shows who trains when',
      contains('Maya Chen') || seen('Completed'),
    );
    check(
      'center has no way to open the note',
      !contains('felt stronger') && find.text('Save log').evaluate().isEmpty,
    );
    await openTab('Center');
    await signOut();
    check(
      'center can sign out',
      await appears(find.text('Log in')),
    );

    expect(failed, isEmpty, reason: failed.join('\n'));
  });
}
