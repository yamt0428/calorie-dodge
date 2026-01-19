import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalendarHeatmap extends StatelessWidget {
  final Map<DateTime, int> data;
  final Function(DateTime)? onDayTap;
  final int weeksToShow;

  const CalendarHeatmap({
    super.key,
    required this.data,
    this.onDayTap,
    this.weeksToShow = 16,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 週の数分の日付を生成（日曜日スタート）
    final startDate = today.subtract(Duration(days: today.weekday % 7 + (weeksToShow - 1) * 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 月の表示
        _buildMonthLabels(startDate),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 曜日ラベル
            _buildWeekdayLabels(),
            const SizedBox(width: 4),
            // ヒートマップ本体
            Expanded(
              child: _buildHeatmapGrid(startDate, today),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 凡例
        _buildLegend(),
      ],
    );
  }

  Widget _buildMonthLabels(DateTime startDate) {
    final months = <Widget>[];
    DateTime current = startDate;
    int? lastMonth;

    for (int week = 0; week < weeksToShow; week++) {
      final weekStart = current.add(Duration(days: week * 7));
      if (lastMonth != weekStart.month) {
        months.add(
          Padding(
            padding: EdgeInsets.only(left: week == 0 ? 24.0 : 0),
            child: SizedBox(
              width: 14.0 * 3,
              child: Text(
                _getMonthName(weekStart.month),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        );
        lastMonth = weekStart.month;
      }
    }

    return Row(children: months);
  }

  Widget _buildWeekdayLabels() {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return Column(
      children: List.generate(7, (index) {
        // 月・水・金のみ表示
        final show = index == 1 || index == 3 || index == 5;
        return SizedBox(
          height: 14,
          width: 20,
          child: Text(
            show ? weekdays[index] : '',
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.textSecondary,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeatmapGrid(DateTime startDate, DateTime today) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: List.generate(weeksToShow, (weekIndex) {
          return Column(
            children: List.generate(7, (dayIndex) {
              final date = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
              final calories = _getCaloriesForDate(date);
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isFuture = date.isAfter(today);

              return GestureDetector(
                onTap: isFuture ? null : () => onDayTap?.call(date),
                child: Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isFuture
                        ? Colors.transparent
                        : AppTheme.getHeatmapColor(calories),
                    borderRadius: BorderRadius.circular(2),
                    border: isToday
                        ? Border.all(color: AppTheme.primaryGreen, width: 1.5)
                        : null,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Less',
          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 4),
        _legendBox(AppTheme.grayLight),
        _legendBox(AppTheme.lightGreen1),
        _legendBox(AppTheme.lightGreen2),
        _legendBox(AppTheme.lightGreen3),
        _legendBox(AppTheme.darkGreen),
        const SizedBox(width: 4),
        const Text(
          'More',
          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  int _getCaloriesForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return data[normalizedDate] ?? 0;
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
