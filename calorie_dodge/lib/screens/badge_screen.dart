import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/badge.dart' show AppBadge, BadgeType;
import '../providers/badge_provider.dart';
import '../providers/record_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/badge_card.dart';

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('バッジ'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'カロリー'),
              Tab(text: '連続記録'),
              Tab(text: '記録回数'),
            ],
          ),
        ),
        body: Consumer2<BadgeProvider, RecordProvider>(
          builder: (context, badgeProvider, recordProvider, child) {
            return TabBarView(
              children: [
                _buildBadgeGrid(
                  context,
                  badgeProvider.getBadgesByType(BadgeType.calories),
                  badgeProvider,
                  recordProvider,
                ),
                _buildBadgeGrid(
                  context,
                  badgeProvider.getBadgesByType(BadgeType.streak),
                  badgeProvider,
                  recordProvider,
                ),
                _buildBadgeGrid(
                  context,
                  badgeProvider.getBadgesByType(BadgeType.count),
                  badgeProvider,
                  recordProvider,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBadgeGrid(
    BuildContext context,
    List<AppBadge> badges,
    BadgeProvider badgeProvider,
    RecordProvider recordProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 獲得状況サマリー
          _buildSummaryCard(badges),
          const SizedBox(height: 16),

          // バッジグリッド
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              final progress = badgeProvider.getBadgeProgress(
                badge,
                totalCalories: recordProvider.totalCalories,
                currentStreak: recordProvider.currentStreak,
                recordCount: recordProvider.recordCount,
              );

              return GestureDetector(
                onTap: () => _showBadgeDetail(context, badge, progress),
                child: BadgeCard(badge: badge, progress: progress),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<AppBadge> badges) {
    final unlockedCount = badges.where((b) => b.isUnlocked).length;
    final totalCount = badges.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.lightGreen1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '🏆',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '獲得済み: $unlockedCount / $totalCount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: unlockedCount / totalCount,
                      minHeight: 8,
                      backgroundColor: AppTheme.grayLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, AppBadge badge, double progress) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                badge.icon,
                style: TextStyle(
                  fontSize: 64,
                  color: badge.isUnlocked ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 20,
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
              const SizedBox(height: 16),
              if (badge.isUnlocked) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '獲得済み ✓',
                    style: TextStyle(
                      color: AppTheme.darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  '進捗',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: AppTheme.grayLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGreen.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
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
      ),
    );
  }
}
