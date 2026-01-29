import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/weight_provider.dart';
import '../models/weight_record.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen>
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
        title: const Text('体重・体脂肪'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '記録'),
            Tab(text: 'グラフ'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecordTab(),
                _buildGraphTab(),
              ],
            ),
          ),
          // バナー広告
          if (Platform.isAndroid || Platform.isIOS) const BannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecordDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('記録'),
      ),
    );
  }

  Widget _buildRecordTab() {
    return Consumer<WeightProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 現在の体重・体脂肪
              _buildCurrentStats(provider),
              const SizedBox(height: 24),

              // 目標設定
              _buildGoalSection(provider),
              const SizedBox(height: 24),

              // 最近の記録
              _buildRecentRecords(provider),
              const SizedBox(height: 80), // FABの余白
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentStats(WeightProvider provider) {
    final latestRecord = provider.latestRecord;
    final goal = provider.goal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '現在の体重',
                    latestRecord != null
                        ? '${latestRecord.weight.toStringAsFixed(1)} kg'
                        : '-- kg',
                    Icons.monitor_weight,
                    goal != null && latestRecord != null
                        ? _getDifferenceText(
                            latestRecord.weight - goal.targetWeight, 'kg')
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    '体脂肪率',
                    latestRecord?.bodyFatPercentage != null
                        ? '${latestRecord!.bodyFatPercentage!.toStringAsFixed(1)} %'
                        : '-- %',
                    Icons.water_drop,
                    goal?.targetBodyFatPercentage != null &&
                            latestRecord?.bodyFatPercentage != null
                        ? _getDifferenceText(
                            latestRecord!.bodyFatPercentage! -
                                goal!.targetBodyFatPercentage!,
                            '%')
                        : null,
                  ),
                ),
              ],
            ),
            if (latestRecord != null) ...[
              const SizedBox(height: 12),
              Text(
                '最終更新: ${DateFormat('M/d HH:mm').format(latestRecord.timestamp)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, String? difference) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppTheme.weightAndFatIconColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (difference != null) ...[
          const SizedBox(height: 4),
          Text(
            difference,
            style: TextStyle(
              fontSize: 12,
              color: difference.startsWith('+')
                  ? Colors.red
                  : AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _getDifferenceText(double diff, String unit) {
    if (diff > 0) {
      return '+${diff.toStringAsFixed(1)} $unit';
    } else if (diff < 0) {
      return '${diff.toStringAsFixed(1)} $unit';
    } else {
      return '目標達成！';
    }
  }

  Widget _buildGoalSection(WeightProvider provider) {
    final goal = provider.goal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '目標',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showGoalDialog(context, provider),
              icon: Icon(goal == null ? Icons.add : Icons.edit, size: 18),
              label: Text(goal == null ? '設定' : '編集'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (goal != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          '目標体重',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${goal.targetWeight.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (goal.targetBodyFatPercentage != null) ...[
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.borderColor,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            '目標体脂肪率',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${goal.targetBodyFatPercentage!.toStringAsFixed(1)} %',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.flag_outlined,
                        size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    const Text(
                      '目標を設定しましょう',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentRecords(WeightProvider provider) {
    final records = provider.records.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '記録履歴',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (records.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.monitor_weight_outlined,
                        size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    const Text(
                      'まだ記録がありません',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.monitor_weight,
                      color: AppTheme.darkGreen,
                    ),
                  ),
                  title: Text(
                    '${record.weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('M/d HH:mm').format(record.timestamp),
                  ),
                  trailing: record.bodyFatPercentage != null
                      ? Text(
                          '${record.bodyFatPercentage!.toStringAsFixed(1)} %',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        )
                      : null,
                  onTap: () => _showEditRecordDialog(context, record),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildGraphTab() {
    return Consumer<WeightProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 期間選択
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
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 体重グラフ
              const Text(
                '体重',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: _buildWeightChart(provider),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 体脂肪率グラフ
              const Text(
                '体脂肪率',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: _buildBodyFatChart(provider),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeightChart(WeightProvider provider) {
    Map<DateTime, double> data;
    String Function(DateTime) labelFormatter;

    switch (_chartPeriod) {
      case 'weekly':
        data = provider.getWeeklyWeights();
        labelFormatter = (date) => DateFormat('M/d').format(date);
        break;
      case 'monthly':
        data = provider.getMonthlyWeights();
        labelFormatter = (date) => DateFormat('M月').format(date);
        break;
      default:
        data = provider.getDailyWeights();
        labelFormatter = (date) => DateFormat('M/d').format(date);
    }

    return _buildLineChart(data, labelFormatter, provider.goal?.targetWeight);
  }

  Widget _buildBodyFatChart(WeightProvider provider) {
    Map<DateTime, double> data;
    String Function(DateTime) labelFormatter;

    switch (_chartPeriod) {
      case 'weekly':
        data = provider.getWeeklyBodyFat();
        labelFormatter = (date) => DateFormat('M/d').format(date);
        break;
      case 'monthly':
        data = provider.getMonthlyBodyFat();
        labelFormatter = (date) => DateFormat('M月').format(date);
        break;
      default:
        data = provider.getDailyBodyFat();
        labelFormatter = (date) => DateFormat('M/d').format(date);
    }

    return _buildLineChart(
        data, labelFormatter, provider.goal?.targetBodyFatPercentage);
  }

  Widget _buildLineChart(
    Map<DateTime, double> data,
    String Function(DateTime) labelFormatter,
    double? targetValue,
  ) {
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
      spots.add(FlSpot(i.toDouble(), data[recentKeys[i]]!));
    }

    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;
    final padding = yRange > 0 ? yRange * 0.1 : maxY * 0.1;

    // horizontalIntervalが0にならないようにする
    final horizontalInterval =
        yRange > 0 ? yRange / 4 : (maxY > 0 ? maxY * 0.1 : 1.0);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: horizontalInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.borderColor,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
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
        extraLinesData: targetValue != null
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: targetValue,
                    color: Colors.red.withValues(alpha: 0.5),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => '目標',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              )
            : null,
        minY:
            yRange > 0 ? minY - padding : minY - (maxY > 0 ? maxY * 0.1 : 1.0),
        maxY:
            yRange > 0 ? maxY + padding : maxY + (maxY > 0 ? maxY * 0.1 : 1.0),
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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
                '体重・体脂肪を記録',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '体重（必須）',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bodyFatController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '体脂肪率（任意）',
                  suffixText: '%',
                  prefixIcon: Icon(Icons.water_drop),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final weight = double.tryParse(weightController.text);
                    if (weight == null || weight <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('正しい体重を入力してください')),
                      );
                      return;
                    }

                    final bodyFat = double.tryParse(bodyFatController.text);

                    context.read<WeightProvider>().addRecord(
                          weight: weight,
                          bodyFatPercentage: bodyFat,
                        );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('記録しました'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                  child: const Text('記録する'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showEditRecordDialog(BuildContext context, WeightRecord record) {
    final weightController =
        TextEditingController(text: record.weight.toString());
    final bodyFatController =
        TextEditingController(text: record.bodyFatPercentage?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '記録を編集',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<WeightProvider>().deleteRecord(record.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('削除しました')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '体重',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bodyFatController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '体脂肪率（任意）',
                  suffixText: '%',
                  prefixIcon: Icon(Icons.water_drop),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final weight = double.tryParse(weightController.text);
                    if (weight == null || weight <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('正しい体重を入力してください')),
                      );
                      return;
                    }

                    final bodyFat = double.tryParse(bodyFatController.text);

                    context.read<WeightProvider>().updateRecord(
                          record.copyWith(
                            weight: weight,
                            bodyFatPercentage: bodyFat,
                          ),
                        );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('更新しました'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                  child: const Text('更新'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showGoalDialog(BuildContext context, WeightProvider provider) {
    final goal = provider.goal;
    final weightController =
        TextEditingController(text: goal?.targetWeight.toString() ?? '');
    final bodyFatController = TextEditingController(
        text: goal?.targetBodyFatPercentage?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '目標を設定',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (goal != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                        provider.deleteGoal();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('目標を削除しました')),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '目標体重（必須）',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.flag),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bodyFatController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '目標体脂肪率（任意）',
                  suffixText: '%',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final weight = double.tryParse(weightController.text);
                    if (weight == null || weight <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('正しい目標体重を入力してください')),
                      );
                      return;
                    }

                    final bodyFat = double.tryParse(bodyFatController.text);

                    provider.setGoal(
                      targetWeight: weight,
                      targetBodyFatPercentage: bodyFat,
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('目標を設定しました'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                  child: const Text('設定'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
