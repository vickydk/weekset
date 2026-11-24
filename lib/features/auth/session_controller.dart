import 'package:flutter/foundation.dart';

import 'auth_api.dart';
import 'token_store.dart';

enum Gate { loading, welcome, locked, suspended, shell }

/// Decides welcome, locked, suspended, or a role shell from /v1/me.
class SessionController extends ChangeNotifier {
  SessionController({required this.api, required this.tokens});

  final AuthApi api;
  final TokenStore tokens;

  Gate gate = Gate.loading;
  Profile? profile;
  String? error;
  String? _refresh;
  String? accessToken;

  Future<void> restore() async {
    final stored = await tokens.read();
    if (stored == null) {
      gate = Gate.welcome;
      notifyListeners();
      return;
    }
    _refresh = stored.refresh;
    try {
      profile = await api.me(stored.access);
    } on AuthException {
      try {
        final session = await api.refresh(stored.refresh);
        await _keep(session);
        profile = session.profile;
      } on AuthException {
        await tokens.clear();
        gate = Gate.welcome;
        notifyListeners();
        return;
      }
    }
    _open(profile!);
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String accountType,
  }) async {
    error = null;
    final session = await api.register(
      email: email,
      password: password,
      displayName: displayName,
      accountType: accountType,
    );
    await _keep(session);
    _open(session.profile);
  }

  Future<void> login({required String email, required String password}) async {
    error = null;
    try {
      final session = await api.login(email: email, password: password);
      await _keep(session);
      _open(session.profile);
    } on AuthException catch (err) {
      error = err.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    final refresh = _refresh;
    await tokens.clear();
    _refresh = null;
    profile = null;
    gate = Gate.welcome;
    notifyListeners();
    if (refresh != null) {
      try {
        await api.logout(refresh);
      } on AuthException {
        // Local sign-out already happened.
      }
    }
  }

  Future<void> adopt(AuthSession session) async {
    error = null;
    await _keep(session);
    _open(session.profile);
  }

  String? inviteCode;

  Future<void> inviteManager(String email, List<String> branchIds) async {
    final access = accessToken;
    if (access == null) return;
    inviteCode = await api.inviteManager(
      accessToken: access,
      email: email,
      branchIds: branchIds,
    );
    notifyListeners();
  }

  /// Returns the error to show, or null when the code opened a center.
  Future<String?> acceptCode(String code) async {
    final access = accessToken;
    if (access == null) return 'invite is not valid';
    try {
      await api.acceptInvite(code);
      profile = await api.me(access);
    } on AuthException catch (err) {
      return err.message;
    }
    _open(profile!);
    if (gate != Gate.shell) return 'invite is not valid';
    return null;
  }

  Future<void> addBranch(String name) async {
    final access = accessToken;
    if (access == null) return;
    await api.addBranch(accessToken: access, name: name);
    profile = await api.me(access);
    _open(profile!);
  }

  Future<void> _keep(AuthSession session) async {
    _refresh = session.refreshToken;
    accessToken = session.accessToken;
    await tokens.write(
      StoredTokens(access: session.accessToken, refresh: session.refreshToken),
    );
  }

  void _open(Profile next) {
    profile = next;
    if (!next.hasActiveMembership && next.onlySuspended) {
      gate = Gate.suspended;
    } else if (!next.hasActiveMembership) {
      gate = Gate.locked;
    } else {
      gate = Gate.shell;
    }
    notifyListeners();
  }
}
