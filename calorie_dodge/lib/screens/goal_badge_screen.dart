import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../models/badge.dart' show AppBadge, BadgeType;
import '../providers/goal_provider.dart';
import '../providers/record_provider.dart';
import '../providers/badge_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/badge_card.dart';

class GoalBadgeScreen extends StatefulWidget {
  const GoalBadgeScreen({super.key});

  @override
  State<GoalBadgeScreen> createState() => _GoalBadgeScreenState();
}

class _GoalBadgeScreenState extends State<GoalBadgeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目標・バッジ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '目標'),
            Tab(text: 'バッジ'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGoalTab(),
                _buildBadgeTab(),
              ],
            ),
          ),
          // バナー広告
          if (Platform.isAndroid || Platform.isIOS) const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildGoalTab() {
    return Consumer2<GoalProvider, RecordProvider>(
      builder: (context, goalProvider, recordProvider, child) {
        final activeGoals = goalProvider.activeGoals;
        final formatter = NumberFormat('#,###');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 現在の連続記録
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.whatshot, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            '連続記録',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStreakInfo(
                            '現在',
                            '${recordProvider.currentStreak}日',
                          ),
                          _buildStreakInfo(
                            '最長',
                            '${recordProvider.maxStreak}日',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // アクティブな目標
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'アクティブな目標',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddGoalDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('追加'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (activeGoals.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '目標が設定されていません',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showAddGoalDialog(context),
                            child: const Text('目標を追加'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...activeGoals.map((goal) {
                  final progress = _calculateProgress(
                    goal,
                    recordProvider,
                    goalProvider,
                  );
                  final currentValue = _getCurrentValue(
                    goal,
                    recordProvider,
                    goalProvider,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                goal.type == GoalType.period
                                    ? Icons.event
                                    : Icons.local_fire_department,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getGoalTitle(goal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                iconSize: 20,
                                onPressed: () => _deleteGoal(
                                  context,
                                  goal,
                                  goalProvider,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: AppTheme.grayLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1.0
                                    ? AppTheme.primaryGreen
                                    : AppTheme.lightGreen2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goal.type == GoalType.period
                                    ? '${formatter.format(currentValue)} / ${formatter.format(goal.targetValue)} kcal'
                                    : '$currentValue / ${goal.targetValue} 日',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: progress >= 1.0
                                      ? AppTheme.primaryGreen
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (progress >= 1.0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGreen1,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '🎉 達成！',
                                style: TextStyle(
                                  color: AppTheme.darkGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeTab() {
    return Consumer2<BadgeProvider, RecordProvider>(
      builder: (context, badgeProvider, recordProvider, child) {
        final allBadges = badgeProvider.badges;
        final unlockedCount = allBadges.where((b) => b.isUnlocked).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // サマリーカード
              Card(
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
                              '獲得済み: $unlockedCount / ${allBadges.length}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: allBadges.isNotEmpty
                                    ? unlockedCount / allBadges.length
                                    : 0,
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
              ),
              const SizedBox(height: 24),

              // カロリーバッジ
              _buildBadgeSection(
                'カロリーバッジ',
                badgeProvider.getBadgesByType(BadgeType.calories),
                badgeProvider,
                recordProvider,
              ),
              const SizedBox(height: 24),

              // 連続記録バッジ
              _buildBadgeSection(
                '連続記録バッジ',
                badgeProvider.getBadgesByType(BadgeType.streak),
                badgeProvider,
                recordProvider,
              ),
              const SizedBox(height: 24),

              // 記録回数バッジ
              _buildBadgeSection(
                '記録回数バッジ',
                badgeProvider.getBadgesByType(BadgeType.count),
                badgeProvider,
                recordProvider,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeSection(
    String title,
    List<AppBadge> badges,
    BadgeProvider badgeProvider,
    RecordProvider recordProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
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
    );
  }

  Widget _buildStreakInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getGoalTitle(Goal goal) {
    if (goal.type == GoalType.period) {
      final periodText = goal.period == GoalPeriod.weekly ? '週間' : '月間';
      return '$periodText ${NumberFormat('#,###').format(goal.targetValue)} kcal 回避';
    } else {
      return '${goal.targetValue}日連続記録';
    }
  }

  double _calculateProgress(
    Goal goal,
    RecordProvider recordProvider,
    GoalProvider goalProvider,
  ) {
    if (goal.type == GoalType.period) {
      final currentCalories = goalProvider.getCaloriesInPeriod(
        goal,
        recordProvider.records,
      );
      return (currentCalories / goal.targetValue).clamp(0.0, 1.0);
    } else {
      return (recordProvider.currentStreak / goal.targetValue).clamp(0.0, 1.0);
    }
  }

  int _getCurrentValue(
    Goal goal,
    RecordProvider recordProvider,
    GoalProvider goalProvider,
  ) {
    if (goal.type == GoalType.period) {
      return goalProvider.getCaloriesInPeriod(goal, recordProvider.records);
    } else {
      return recordProvider.currentStreak;
    }
  }

  void _deleteGoal(BuildContext context, Goal goal, GoalProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目標を削除'),
        content: const Text('この目標を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteGoal(goal.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AddGoalSheet(),
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
                badge.name.replaceAll('\n', ''),
                textAlign: TextAlign.center,
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

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  GoalType _selectedType = GoalType.period;
  GoalPeriod _selectedPeriod = GoalPeriod.weekly;
  final _targetController = TextEditingController(text: '5000');

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '目標を追加',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // 目標タイプ選択
          const Text('目標タイプ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<GoalType>(
            segments: const [
              ButtonSegment(
                value: GoalType.period,
                label: Text('期間ベース'),
                icon: Icon(Icons.event),
              ),
              ButtonSegment(
                value: GoalType.streak,
                label: Text('連続記録'),
                icon: Icon(Icons.local_fire_department),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (value) {
              setState(() {
                _selectedType = value.first;
                if (_selectedType == GoalType.period) {
                  _targetController.text = '5000';
                } else {
                  _targetController.text = '7';
                }
              });
            },
          ),
          const SizedBox(height: 24),

          if (_selectedType == GoalType.period) ...[
            // 期間選択
            const Text('期間', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<GoalPeriod>(
              segments: const [
                ButtonSegment(value: GoalPeriod.weekly, label: Text('週間')),
                ButtonSegment(value: GoalPeriod.monthly, label: Text('月間')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (value) {
                setState(() => _selectedPeriod = value.first);
              },
            ),
            const SizedBox(height: 24),
          ],

          // 目標値入力
          Text(
            _selectedType == GoalType.period ? '目標カロリー' : '目標日数',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              suffixText: _selectedType == GoalType.period ? 'kcal' : '日',
            ),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 32),

          // 追加ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addGoal,
              child: const Text('目標を追加'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _addGoal() {
    final targetValue = int.tryParse(_targetController.text);
    if (targetValue == null || targetValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正しい値を入力してください')),
      );
      return;
    }

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (_selectedType == GoalType.period) {
      if (_selectedPeriod == GoalPeriod.weekly) {
        // 週の開始日（月曜日）
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 6));
      } else {
        // 月の開始日
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
      }
    } else {
      startDate = now;
      endDate = now.add(Duration(days: targetValue));
    }

    context.read<GoalProvider>().addGoal(
          type: _selectedType,
          targetValue: targetValue,
          period: _selectedPeriod,
          startDate: startDate,
          endDate: endDate,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('目標を追加しました'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}
