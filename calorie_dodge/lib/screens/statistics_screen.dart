import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/record_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/banner_ad_widget.dart';
import 'record_detail_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _chartPeriod = 'daily'; // daily, weekly, monthly

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
        title: const Text('統計'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'グラフ'),
            Tab(text: '記録一覧'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGraphTab(),
                _buildRecordListTab(),
              ],
            ),
          ),
          // バナー広告
          if (Platform.isAndroid || Platform.isIOS) const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildGraphTab() {
    return Consumer<RecordProvider>(
      builder: (context, provider, child) {
        final stats = provider.getStatistics();
        final formatter = NumberFormat('#,###');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 統計カード
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    title: '総記録回数',
                    value: '${stats['recordCount']}回',
                    icon: Icons.edit_note,
                  ),
                  StatCard(
                    title: '累計カロリー',
                    value: '${formatter.format(stats['totalCalories'])} kcal',
                    icon: Icons.local_fire_department,
                  ),
                  StatCard(
                    title: '最長連続記録',
                    value: '${stats['maxStreak']}日',
                    icon: Icons.whatshot,
                  ),
                  StatCard(
                    title: '多い時間帯',
                    value: stats['mostActiveTimeOfDay'] ?? '-',
                    icon: Icons.schedule,
                  ),
                  StatCard(
                    title: '1日最大',
                    value:
                        '${formatter.format(stats['maxDailyCalories'])} kcal',
                    icon: Icons.trending_up,
                  ),
                  StatCard(
                    title: '平均/1回',
                    value:
                        '${(stats['averageCaloriesPerRecord'] as double).toStringAsFixed(0)} kcal',
                    icon: Icons.analytics,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // グラフ期間選択
              Row(
                children: [
                  const Text(
                    '推移グラフ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'daily', label: Text('日')),
                      ButtonSegment(value: 'weekly', label: Text('週')),
                      ButtonSegment(value: 'monthly', label: Text('月')),
                    ],
                    selected: {_chartPeriod},
                    onSelectionChanged: (value) {
                      setState(() => _chartPeriod = value.first);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // グラフ
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 250,
                    child: _buildChart(provider),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(RecordProvider provider) {
    Map<DateTime, int> data;
    String Function(DateTime) labelFormatter;

    switch (_chartPeriod) {
      case 'weekly':
        data = provider.getWeeklyCalories();
        labelFormatter = (date) => DateFormat('M/d').format(date);
        break;
      case 'monthly':
        data = provider.getMonthlyCalories();
        labelFormatter = (date) => DateFormat('M月').format(date);
        break;
      default:
        data = provider.getDailyCalories();
        labelFormatter = (date) => DateFormat('M/d').format(date);
    }

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'データがありません',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final sortedKeys = data.keys.toList()..sort();
    final recentKeys = sortedKeys.length > 10
        ? sortedKeys.sublist(sortedKeys.length - 10)
        : sortedKeys;

    final spots = <FlSpot>[];
    for (var i = 0; i < recentKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[recentKeys[i]]!.toDouble()));
    }

    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 100,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.borderColor,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= recentKeys.length) {
                  return const SizedBox();
                }
                // 表示するラベルの間隔を調整
                if (recentKeys.length > 5 && index % 2 != 0) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labelFormatter(recentKeys[index]),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryGreen,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppTheme.primaryGreen,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            ),
          ),
        ],
        minY: 0,
      ),
    );
  }

  Widget _buildRecordListTab() {
    return Consumer<RecordProvider>(
      builder: (context, provider, child) {
        final records = provider.records;
        final formatter = NumberFormat('#,###');

        if (records.isEmpty) {
          return const Center(
            child: Text(
              'まだ記録がありません',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        // 日付でグループ化
        final groupedRecords = <DateTime, List<dynamic>>{};
        for (final record in records) {
          final date = DateTime(
            record.timestamp.year,
            record.timestamp.month,
            record.timestamp.day,
          );
          groupedRecords.putIfAbsent(date, () => []).add(record);
        }

        final sortedDates = groupedRecords.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dayRecords = groupedRecords[date]!;
            final totalCalories = dayRecords.fold<int>(
              0,
              (sum, r) => sum + (r.calories as int),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('M月d日（E）', 'ja').format(date),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${formatter.format(totalCalories)} kcal',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dayRecords.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final record = dayRecords[index];
                      return ListTile(
                        title: Text(
                          record.memo?.isNotEmpty == true
                              ? record.memo!
                              : '${formatter.format(record.calories)} kcal',
                        ),
                        subtitle: Text(
                          DateFormat('HH:mm').format(record.timestamp),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          '${formatter.format(record.calories)} kcal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
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
                const SizedBox(height: 8),
              ],
            );
          },
        );
      },
    );
  }
}
