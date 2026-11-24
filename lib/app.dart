import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth_api.dart';
import 'features/auth/auth_gate.dart';
import 'features/auth/secure_token_store.dart';
import 'features/auth/session_controller.dart';
import 'features/auth/token_store.dart';

class WeeksetApp extends StatefulWidget {
  const WeeksetApp({this.api, this.tokens, super.key});

  final AuthApi? api;
  final TokenStore? tokens;

  @override
  State<WeeksetApp> createState() => _WeeksetAppState();
}

class _WeeksetAppState extends State<WeeksetApp> {
  late final SessionController _session = SessionController(
    api: widget.api ?? AuthApi(),
    tokens: widget.tokens ?? const SecureTokenStore(),
  );

  @override
  void initState() {
    super.initState();
    _session.restore();
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weekset',
      theme: AppTheme.dark(),
      home: AuthGate(session: _session),
    );
  }
}
