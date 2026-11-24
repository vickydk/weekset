import 'dart:convert';

import 'package:http/http.dart' as http;

/// The signed-in person. Memberships decide whether a menu opens.
class Profile {
  const Profile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.accountType,
    required this.memberships,
  });

  final String id;
  final String email;
  final String displayName;
  final String accountType;
  final List<Membership> memberships;

  bool get hasActiveMembership =>
      memberships.any((row) => row.status == 'active');

  bool get onlySuspended =>
      memberships.isNotEmpty &&
      memberships.every((row) => row.status == 'suspended');

  Membership? get activeMembership {
    for (final row in memberships) {
      if (row.status == 'active') return row;
    }
    return null;
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    final raw = json['memberships'] as List<dynamic>? ?? const [];
    return Profile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      accountType: json['account_type'] as String? ?? '',
      memberships: raw
          .map((row) => Membership.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Membership {
  const Membership({
    required this.role,
    required this.status,
    required this.fitnessCenterId,
    required this.centerName,
    this.branchName,
  });

  final String role;
  final String status;
  final String fitnessCenterId;
  final String centerName;
  final String? branchName;

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      fitnessCenterId: json['fitness_center_id'] as String? ?? '',
      centerName: json['center_name'] as String? ?? '',
      branchName: json['branch_name'] as String?,
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.profile,
  });

  final String accessToken;
  final String refreshToken;
  final Profile profile;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      profile: Profile.fromJson(json),
    );
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

/// Talks to /v1/auth and /v1/me.
class AuthApi {
  AuthApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_URL',
            defaultValue: 'http://localhost:8080',
          );

  final http.Client _client;
  final String baseUrl;

  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
    required String accountType,
  }) {
    return _session('POST', '/v1/auth/register', {
      'email': email,
      'password': password,
      'display_name': displayName,
      'account_type': accountType,
    });
  }

  Future<AuthSession> login({required String email, required String password}) {
    return _session('POST', '/v1/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<AuthSession> refresh(String refreshToken) {
    return _session('POST', '/v1/auth/refresh', {
      'refresh_token': refreshToken,
    });
  }

  Future<void> logout(String refreshToken) async {
    await _send('POST', '/v1/auth/logout', {'refresh_token': refreshToken});
  }

  Future<void> forgot(String email) async {
    await _send('POST', '/v1/auth/password/forgot', {'email': email});
  }

  Future<Profile> me(String accessToken) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/v1/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 401) {
      throw const AuthException('unauthorized');
    }
    if (response.statusCode != 200) {
      throw const AuthException('unexpected error');
    }
    return Profile.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AuthSession> _session(
    String method,
    String path,
    Map<String, Object> body,
  ) async {
    final response = await _send(method, path, body);
    if (response.statusCode == 401) {
      throw const AuthException('That email or password is not right.');
    }
    if (response.statusCode == 409) {
      throw const AuthException('email already in use');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw const AuthException('unexpected error');
    }
    return AuthSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<http.Response> _send(
    String method,
    String path,
    Map<String, Object> body,
  ) {
    return _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }
}
