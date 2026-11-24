import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_chip.dart';

/// The first tab. Workout notes, sets, reps, and load are not on this card.
class HomeCard {
  const HomeCard({
    required this.question,
    required this.centerName,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.primaryAction,
    this.branchName = '',
    this.sessions = const [],
    this.attention = const [],
  });

  final String question;
  final String centerName;
  final String branchName;
  final String emptyTitle;
  final String emptyMessage;
  final String primaryAction;
  final List<HomeSession> sessions;
  final List<String> attention;

  bool get isEmpty =>
      sessions.isEmpty && attention.isEmpty && emptyTitle.isNotEmpty;

  factory HomeCard.fromJson(Map<String, dynamic> json) {
    final sessions = json['sessions'] as List<dynamic>? ?? const [];
    final attention = json['attention'] as List<dynamic>? ?? const [];
    return HomeCard(
      question: json['question'] as String? ?? '',
      centerName: json['center_name'] as String? ?? '',
      branchName: json['branch_name'] as String? ?? '',
      emptyTitle: json['empty_title'] as String? ?? '',
      emptyMessage: json['empty_message'] as String? ?? '',
      primaryAction: json['primary_action'] as String? ?? '',
      sessions: sessions
          .map((row) => HomeSession.fromJson(row as Map<String, dynamic>))
          .toList(),
      attention: attention
          .map((row) => (row as Map<String, dynamic>)['label'] as String? ?? '')
          .where((label) => label.isNotEmpty)
          .toList(),
    );
  }

  static HomeCard emptyFor(
    String? role, {
    String centerName = '',
    String branchName = '',
  }) {
    return switch (role) {
      'trainer' => HomeCard(
        question: 'Who needs me today?',
        centerName: centerName,
        branchName: branchName,
        emptyTitle: 'No one booked.',
        emptyMessage: 'Set hours',
        primaryAction: 'Set hours',
      ),
      'manager' => HomeCard(
        question: 'What is stuck at this branch?',
        centerName: centerName,
        branchName: branchName,
        emptyTitle: 'No one at this branch yet',
        emptyMessage: 'Invite.',
        primaryAction: 'Invite',
      ),
      'center_admin' => HomeCard(
        question: 'Which branch needs an owner?',
        centerName: centerName,
        branchName: branchName,
        emptyTitle:
            'Invite a manager for ${branchName.isEmpty ? 'this branch' : branchName}.',
        emptyMessage: 'Invite a manager',
        primaryAction: 'Invite a manager',
      ),
      _ => HomeCard(
        question: 'What do I do next?',
        centerName: centerName,
        branchName: branchName,
        emptyTitle: 'No session today',
        emptyMessage: 'See open hours.',
        primaryAction: 'See open hours',
      ),
    };
  }
}

class HomeSession {
  const HomeSession({
    required this.time,
    required this.title,
    required this.status,
  });

  final String time;
  final String title;
  final SessionStatus status;

  factory HomeSession.fromJson(Map<String, dynamic> json) {
    final status = switch (json['status'] as String? ?? '') {
      'confirmed' => SessionStatus.confirmed,
      'completed' => SessionStatus.completed,
      'declined' => SessionStatus.declined,
      'cancelled' => SessionStatus.cancelled,
      _ => SessionStatus.requested,
    };
    final client = json['client_name'] as String? ?? '';
    final trainer = json['trainer_name'] as String? ?? '';
    return HomeSession(
      time: json['time'] as String? ?? '',
      title: client.isEmpty ? trainer : client,
      status: status,
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({required this.card, required this.onPrimary, super.key});

  final HomeCard card;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Text(
          card.question,
          style: const TextStyle(
            color: AppColors.paper,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (card.attention.isNotEmpty)
          for (final label in card.attention)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label,
                style: const TextStyle(color: AppColors.paper, fontSize: 16),
              ),
            ),
        if (card.sessions.isEmpty && card.emptyTitle.isNotEmpty)
          EmptyState(title: card.emptyTitle, message: card.emptyMessage),
        for (final session in card.sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  session.time,
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    session.title,
                    style: const TextStyle(
                      color: AppColors.paper,
                      fontSize: 16,
                    ),
                  ),
                ),
                StatusChip(status: session.status),
              ],
            ),
          ),
        const SizedBox(height: 16),
        PrimaryButton(label: card.primaryAction, onPressed: onPrimary),
      ],
    );
  }
}
