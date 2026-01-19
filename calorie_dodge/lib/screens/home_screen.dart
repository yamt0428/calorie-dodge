import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/record_provider.dart';
import '../providers/badge_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/badge_card.dart';
import 'record_input_screen.dart';
import 'record_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkBadges();
  }

  void _checkBadges() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recordProvider = context.read<RecordProvider>();
      final badgeProvider = context.read<BadgeProvider>();

      badgeProvider.checkAndUpdateBadges(
        totalCalories: recordProvider.totalCalories,
        currentStreak: recordProvider.currentStreak,
        recordCount: recordProvider.recordCount,
      );
    });
  }

  void _showBadgeDialog(BuildContext context) {
    final badgeProvider = context.read<BadgeProvider>();
    if (badgeProvider.newlyUnlockedBadge != null) {
      showDialog(
        context: context,
        builder: (context) => BadgeUnlockDialog(
          badge: badgeProvider.newlyUnlockedBadge!,
        ),
      ).then((_) {
        badgeProvider.clearNewlyUnlockedBadge();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecordProvider, BadgeProvider>(
      builder: (context, recordProvider, badgeProvider, child) {
        // 新しいバッジ獲得時にダイアログを表示
        if (badgeProvider.newlyUnlockedBadge != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showBadgeDialog(context);
          });
        }

        final dailyCalories = recordProvider.getDailyCalories();
        final formatter = NumberFormat('#,###');

        return Scaffold(
          appBar: AppBar(
            title: const Text('カロリーセーブ'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 今日の回避カロリー
                _buildTodayCard(recordProvider, formatter),
                const SizedBox(height: 16),

                // 累計・連続記録カード
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '累計',
                        '${formatter.format(recordProvider.totalCalories)} kcal',
                        Icons.local_fire_department,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '連続記録',
                        '${recordProvider.currentStreak} 日',
                        Icons.whatshot,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // カレンダーヒートマップ
                const Text(
                  '記録カレンダー',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CalendarHeatmap(
                      data: dailyCalories,
                      onDayTap: (date) => _showDayDetail(context, date, recordProvider),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 最近の記録
                _buildRecentRecords(recordProvider, formatter),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecordInputScreen(),
                ),
              );
              _checkBadges();
            },
            icon: const Icon(Icons.add),
            label: const Text('記録する'),
          ),
        );
      },
    );
  }

  Widget _buildTodayCard(RecordProvider provider, NumberFormat formatter) {
    return Card(
      color: AppTheme.primaryGreen,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  DateFormat('M月d日（E）', 'ja').format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  formatter.format(provider.todayCalories),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'kcal',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '今日の回避カロリー',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecords(RecordProvider provider, NumberFormat formatter) {
    final recentRecords = provider.records.take(5).toList();

    if (recentRecords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 48,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                const Text(
                  'まだ記録がありません',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '誘惑に勝ったらすぐに記録しましょう！',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近の記録',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentRecords.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = recentRecords[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppTheme.darkGreen,
                  ),
                ),
                title: Text(
                  record.memo?.isNotEmpty == true
                      ? record.memo!
                      : '${formatter.format(record.calories)} kcal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat('M/d HH:mm').format(record.timestamp),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  '${formatter.format(record.calories)} kcal',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDayDetail(BuildContext context, DateTime date, RecordProvider provider) {
    final records = provider.getRecordsForDate(date);
    final formatter = NumberFormat('#,###');
    final totalCalories = records.fold(0, (sum, r) => sum + r.calories);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('M月d日（E）', 'ja').format(date),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${formatter.format(totalCalories)} kcal',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: records.isEmpty
                      ? const Center(
                          child: Text(
                            'この日の記録はありません',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            return ListTile(
                              title: Text(
                                record.memo?.isNotEmpty == true
                                    ? record.memo!
                                    : '${formatter.format(record.calories)} kcal',
                              ),
                              subtitle: Text(
                                DateFormat('HH:mm').format(record.timestamp),
                              ),
                              trailing: Text(
                                '${formatter.format(record.calories)} kcal',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecordDetailScreen(
                                      record: record,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
