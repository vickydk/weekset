import 'dart:convert';

import 'package:http/http.dart' as http;

import '../home/home_card.dart';
import '../schedule/availability_week.dart';
import '../schedule/client_week.dart';
import '../schedule/inbox.dart';
import '../schedule/session_log.dart';
import '../exercise/exercise_library.dart';

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

class BranchName {
  const BranchName({required this.id, required this.name});

  final String id;
  final String name;
}

class Membership {
  const Membership({
    required this.role,
    required this.status,
    required this.fitnessCenterId,
    required this.centerName,
    this.branchName,
    this.branches = const [],
  });

  final String role;
  final String status;
  final String fitnessCenterId;
  final String centerName;
  final String? branchName;
  final List<BranchName> branches;

  factory Membership.fromJson(Map<String, dynamic> json) {
    final raw = json['branches'] as List<dynamic>? ?? const [];
    return Membership(
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      fitnessCenterId: json['fitness_center_id'] as String? ?? '',
      centerName: json['center_name'] as String? ?? '',
      branchName: json['branch_name'] as String?,
      branches: raw
          .map(
            (row) => BranchName(
              id: (row as Map<String, dynamic>)['id'] as String? ?? '',
              name: row['name'] as String? ?? '',
            ),
          )
          .toList(),
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

class PersonRow {
  const PersonRow({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.status,
    required this.branchId,
    required this.branchName,
    required this.trainerName,
  });

  final String userId;
  final String displayName;
  final String email;
  final String role;
  final String status;
  final String branchId;
  final String branchName;
  final String trainerName;

  factory PersonRow.fromJson(Map<String, dynamic> json) {
    return PersonRow(
      userId: json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      branchId: json['branch_id'] as String? ?? '',
      branchName: json['branch_name'] as String? ?? '',
      trainerName: json['trainer_name'] as String? ?? '',
    );
  }
}

class OpenInvite {
  const OpenInvite({
    required this.email,
    required this.role,
    required this.branchName,
  });

  final String email;
  final String role;
  final String branchName;

  factory OpenInvite.fromJson(Map<String, dynamic> json) {
    return OpenInvite(
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      branchName: json['branch_name'] as String? ?? '',
    );
  }
}

class PeoplePage {
  const PeoplePage({required this.people, required this.invites});

  final List<PersonRow> people;
  final List<OpenInvite> invites;

  factory PeoplePage.fromJson(Map<String, dynamic> json) {
    final people = json['people'] as List<dynamic>? ?? const [];
    final invites = json['invites'] as List<dynamic>? ?? const [];
    return PeoplePage(
      people: people
          .map((row) => PersonRow.fromJson(row as Map<String, dynamic>))
          .toList(),
      invites: invites
          .map((row) => OpenInvite.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }
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

  Future<AuthSession> openCenter({
    required String email,
    required String password,
    required String displayName,
    required String centerName,
    required String branchName,
    required String timezone,
  }) {
    return _session('POST', '/v1/fitness-centers', {
      'email': email,
      'password': password,
      'display_name': displayName,
      'center_name': centerName,
      'branch_name': branchName,
      'timezone': timezone,
    });
  }

  Future<Map<String, dynamic>> addBranch({
    required String accessToken,
    required String name,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/v1/branches'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode != 201) {
      throw const AuthException('unexpected error');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<String> inviteManager({
    required String accessToken,
    required String email,
    required List<String> branchIds,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/v1/invites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'email': email,
        'role': 'manager',
        'branch_ids': branchIds,
      }),
    );
    if (response.statusCode != 201) {
      throw const AuthException('That person cannot be invited.');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['code'] as String? ?? '';
  }

  Future<void> acceptInvite(String code) async {
    final response = await _send('POST', '/v1/invites/accept', {'code': code});
    if (response.statusCode == 204) return;
    throw AuthException(_errorMessage(response, 'invite is not valid'));
  }

  Future<HomeCard> home({
    required String accessToken,
    String? centerId,
    String? branchId,
  }) async {
    final response = await _authed(
      'GET',
      '/v1/home',
      accessToken,
      branchId: branchId,
      centerId: centerId,
    );
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(response, 'unexpected error'));
    }
    return HomeCard.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AvailabilityPage> availability({
    required String accessToken,
    required String from,
    required String to,
    String? centerId,
  }) async {
    final response = await _authed(
      'GET',
      '/v1/availability?from=$from&to=$to',
      accessToken,
      centerId: centerId,
    );
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(response, 'unexpected error'));
    }
    return AvailabilityPage.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> replaceTemplate({
    required String accessToken,
    required List<TemplateWindow> windows,
    String? centerId,
  }) async {
    final response = await _authed(
      'PUT',
      '/v1/availability/template',
      accessToken,
      centerId: centerId,
      body: {
        'windows': [
          for (final window in windows)
            {
              'weekday': window.weekday,
              'local_start': window.localStart,
              'local_end': window.localEnd,
            },
        ],
      },
    );
    if (response.statusCode != 204) {
      throw AuthException(_errorMessage(response, 'check the hours'));
    }
  }

  Future<void> closeHour({
    required String accessToken,
    required String startsAt,
    required String endsAt,
    String? centerId,
  }) async {
    final response = await _authed(
      'POST',
      '/v1/availability/exceptions',
      accessToken,
      centerId: centerId,
      body: {'starts_at': startsAt, 'ends_at': endsAt},
    );
    if (response.statusCode != 201) {
      throw AuthException(_errorMessage(response, 'check the hours'));
    }
  }

  Future<void> reopenHour({
    required String accessToken,
    required String id,
    String? centerId,
  }) async {
    final response = await _authed(
      'DELETE',
      '/v1/availability/exceptions/$id',
      accessToken,
      centerId: centerId,
    );
    if (response.statusCode != 204) {
      throw AuthException(_errorMessage(response, 'check the hours'));
    }
  }

  Future<List<WeekBooking>> bookings({
    required String accessToken,
    required String from,
    required String to,
    String? centerId,
  }) async {
    final response = await _authed(
      'GET',
      '/v1/bookings?from=$from&to=$to',
      accessToken,
      centerId: centerId,
    );
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(response, 'unexpected error'));
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return [
      for (final raw in json['bookings'] as List<dynamic>? ?? [])
        WeekBooking.fromJson(raw as Map<String, dynamic>),
    ];
  }

  Future<void> requestBooking({
    required String accessToken,
    required String startsAt,
    required String endsAt,
    String? centerId,
  }) async {
    final response = await _authed(
      'POST',
      '/v1/bookings',
      accessToken,
      centerId: centerId,
      body: {'starts_at': startsAt, 'ends_at': endsAt},
    );
    if (response.statusCode != 201) {
      throw AuthException(_errorMessage(response, 'hour is already booked'));
    }
  }

  Future<void> repeatBooking({
    required String accessToken,
    required String startsAt,
    required String endsAt,
    String? centerId,
  }) async {
    final response = await _authed(
      'POST',
      '/v1/booking-series',
      accessToken,
      centerId: centerId,
      body: {'starts_at': startsAt, 'ends_at': endsAt},
    );
    if (response.statusCode != 201) {
      throw AuthException(_errorMessage(response, 'hour is already booked'));
    }
  }

  Future<void> skipOccurrence({
    required String accessToken,
    required String seriesId,
    required String occurrenceOn,
    String? centerId,
  }) async {
    final response = await _authed(
      'POST',
      '/v1/booking-series/$seriesId/skip',
      accessToken,
      centerId: centerId,
      body: {'occurrence_on': occurrenceOn},
    );
    if (response.statusCode != 204) {
      throw AuthException(_errorMessage(response, 'check the hours'));
    }
  }

  Future<void> decideBooking({
    required String accessToken,
    required String id,
    required String action,
    String? centerId,
    String? branchId,
  }) async {
    final response = await _authed(
      'POST',
      '/v1/bookings/$id/$action',
      accessToken,
      centerId: centerId,
      branchId: branchId,
    );
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(response, 'check the hours'));
    }
  }

  Future<List<WeekBooking>> timetable({
    required String accessToken,
    required String from,
    required String to,
    String? centerId,
    String? branchId,
  }) async {
    final response = await _authed(
      'GET',
      '/v1/timetable?from=$from&to=$to',
      accessToken,
      centerId: centerId,
      branchId: branchId,
    );
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(response, 'unexpected error'));
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return [
      for (final raw in json['sessions'] as List<dynamic>? ?? [])
        WeekBooking.fromJson(raw as Map<String, dynamic>),
    ];
  }

  Future<List<Notice>> notifications({
    required String accessToken,
    String? centerId,
  }) async {
    final response = await _authed(
      'GET',
      '/v1/notifications',
      accessToken,
      centerId: centerId,
    );
    if (response.statusCode != 200) {
      throw const AuthException('unexpected error');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return [
      for (final raw in json['notifications'] as List<dynamic>? ?? [])
        Notice.fromJson(raw as Map<String, dynamic>),
    ];
  }

  Future<Notice> openNotification({
    required String accessToken,
    required String id,
    String? centerId,
  }) async {
    final response = await _authed(
      'POST',
      '/v1/notifications/$id/read',
      accessToken,
      centerId: centerId,
    );
    if (response.statusCode != 200) {
      throw const AuthException('unexpected error');
    }
    return Notice.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Movement>> exercises({required String accessToken}) async {
    final response = await _authed('GET', '/v1/exercises', accessToken);
    if (response.statusCode != 200) {
      throw const AuthException('unexpected error');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return [
      for (final raw in json['exercises'] as List<dynamic>? ?? [])
        Movement.fromJson(raw as Map<String, dynamic>),
    ];
  }

  Future<void> writeLog({
    required String accessToken,
    required String bookingId,
    required String note,
    required String exercise,
    required int reps,
    required String load,
    String? centerId,
  }) async {
    final response = await _authed(
      'PUT',
      '/v1/bookings/$bookingId/log',
      accessToken,
      centerId: centerId,
      body: {
        'note': note,
        'exercises': [
          {
            'name': exercise,
            'sets': [
              {'reps': reps, 'load': load, 'unit': 'kg'},
            ],
          },
        ],
      },
    );
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(response, 'check the session'));
    }
  }

  Future<SessionLogView> readLog({
    required String accessToken,
    required String bookingId,
    String? centerId,
  }) async {
    final response = await _authed(
      'GET',
      '/v1/bookings/$bookingId/log',
      accessToken,
      centerId: centerId,
    );
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(response, 'not found'));
    }
    return SessionLogView.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<PeoplePage> people({
    required String accessToken,
    String? branchId,
  }) async {
    final response = await _authed(
      'GET',
      '/v1/people',
      accessToken,
      branchId: branchId,
    );
    if (response.statusCode != 200) {
      throw const AuthException('unexpected error');
    }
    return PeoplePage.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<String> invitePerson({
    required String accessToken,
    required String email,
    required String role,
    required String branchId,
    String? headerBranchId,
  }) async {
    final response = await _authed(
      'POST',
      '/v1/invites',
      accessToken,
      branchId: headerBranchId,
      body: {'email': email, 'role': role, 'branch_id': branchId},
    );
    if (response.statusCode != 201) {
      throw AuthException(
        _errorMessage(response, 'That person cannot be invited.'),
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['code'] as String? ?? '';
  }

  Future<void> assignTrainer({
    required String accessToken,
    required String clientUserId,
    required String trainerUserId,
    String? branchId,
  }) async {
    final response = await _authed(
      'POST',
      '/v1/assignments',
      accessToken,
      branchId: branchId,
      body: {'client_user_id': clientUserId, 'trainer_user_id': trainerUserId},
    );
    if (response.statusCode != 204) {
      throw AuthException(
        _errorMessage(response, 'That PT is not at this branch.'),
      );
    }
  }

  Future<void> suspendPerson({
    required String accessToken,
    required String userId,
    String? branchId,
  }) {
    return _personAction(accessToken, userId, 'suspend', branchId);
  }

  Future<void> restorePerson({
    required String accessToken,
    required String userId,
    String? branchId,
  }) {
    return _personAction(accessToken, userId, 'restore', branchId);
  }

  Future<void> removePerson({
    required String accessToken,
    required String userId,
    String? branchId,
  }) async {
    final response = await _authed(
      'DELETE',
      '/v1/people/$userId',
      accessToken,
      branchId: branchId,
    );
    if (response.statusCode != 204) {
      throw const AuthException('That person cannot be removed.');
    }
  }

  Future<void> replaceManagerBranches({
    required String accessToken,
    required String userId,
    required List<String> branchIds,
  }) async {
    final response = await _authed(
      'PATCH',
      '/v1/people/$userId',
      accessToken,
      body: {'branch_ids': branchIds},
    );
    if (response.statusCode != 204) {
      throw const AuthException('Those branches cannot be saved.');
    }
  }

  Future<void> _personAction(
    String accessToken,
    String userId,
    String action,
    String? branchId,
  ) async {
    final response = await _authed(
      'POST',
      '/v1/people/$userId/$action',
      accessToken,
      branchId: branchId,
    );
    if (response.statusCode != 204) {
      throw const AuthException('That change was not allowed.');
    }
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

  Future<http.Response> _authed(
    String method,
    String path,
    String accessToken, {
    String? branchId,
    String? centerId,
    Object? body,
  }) {
    final headers = {
      'Authorization': 'Bearer $accessToken',
      if (body != null) 'Content-Type': 'application/json',
      if (centerId != null && centerId.isNotEmpty) 'X-Weekset-Center': centerId,
      if (branchId != null && branchId.isNotEmpty) 'X-Weekset-Branch': branchId,
    };
    final uri = Uri.parse('$baseUrl$path');
    return switch (method) {
      'GET' => _client.get(uri, headers: headers),
      'DELETE' => _client.delete(uri, headers: headers),
      'PATCH' => _client.patch(uri, headers: headers, body: jsonEncode(body)),
      'PUT' => _client.put(uri, headers: headers, body: jsonEncode(body)),
      _ => _client.post(uri, headers: headers, body: jsonEncode(body)),
    };
  }

  String _errorMessage(http.Response response, String fallback) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String?;
      if (message != null && message.isNotEmpty) return message;
    } on Object {
      // The fallback is safe to show.
    }
    return fallback;
  }
}
