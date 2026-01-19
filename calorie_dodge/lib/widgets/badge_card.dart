import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../theme/app_theme.dart';

class BadgeCard extends StatelessWidget {
  final AppBadge badge;
  final double progress;

  const BadgeCard({
    super.key,
    required this.badge,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: badge.isUnlocked ? AppTheme.cardColor : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.icon,
              style: TextStyle(
                fontSize: 40,
                color: badge.isUnlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: badge.isUnlocked
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            if (!badge.isUnlocked) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.grayLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ] else ...[
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BadgeUnlockDialog extends StatelessWidget {
  final AppBadge badge;

  const BadgeUnlockDialog({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 新しいバッジ獲得！',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              badge.icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
