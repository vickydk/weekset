import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A named choice. The current row carries the word Current.
class SwitcherOption {
  const SwitcherOption({required this.id, required this.title, this.subtitle});

  final String id;
  final String title;
  final String? subtitle;
}

class OptionSwitcher extends StatelessWidget {
  const OptionSwitcher({
    required this.options,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<SwitcherOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in options) ...[
          Material(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: InkWell(
              onTap: () => onSelected(option.id),
              borderRadius: BorderRadius.circular(AppTheme.radius),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: const TextStyle(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (option.subtitle != null)
                            Text(
                              option.subtitle!,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (option.id == selectedId)
                      const Text(
                        'Current',
                        style: TextStyle(
                          color: AppColors.lime,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// The client's centers. Used on Profile when there is more than one.
class CenterSwitcher extends StatelessWidget {
  const CenterSwitcher({
    required this.centers,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<SwitcherOption> centers;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return OptionSwitcher(
      options: centers,
      selectedId: selectedId,
      onSelected: onSelected,
    );
  }
}

/// The manager's branches.
class BranchSwitcher extends StatelessWidget {
  const BranchSwitcher({
    required this.branches,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<SwitcherOption> branches;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return OptionSwitcher(
      options: branches,
      selectedId: selectedId,
      onSelected: onSelected,
    );
  }
}
