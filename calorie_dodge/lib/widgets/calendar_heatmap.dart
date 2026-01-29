import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalendarHeatmap extends StatefulWidget {
  final Map<DateTime, int> data;
  final Function(DateTime)? onDayTap;
  final int weeksToShow;

  // セルサイズ（タップしやすいように大きめに設定）
  static const double cellSize = 28.0;
  static const double cellMargin = 3.0;
  static const double cellRadius = 6.0;

  const CalendarHeatmap({
    super.key,
    required this.data,
    this.onDayTap,
    this.weeksToShow = 20,
  });

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // ウィジェットがビルドされた後に右端（最新）にスクロール
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 週の数分の日付を生成（日曜日スタート）
    final startDate = today.subtract(
        Duration(days: today.weekday % 7 + (widget.weeksToShow - 1) * 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ヒートマップ本体（横スクロール可能）
        SizedBox(
          height:
              (CalendarHeatmap.cellSize + CalendarHeatmap.cellMargin * 2) * 7 +
                  30, // 7日分 + 月ラベル
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 曜日ラベル（固定）
              _buildWeekdayLabels(),
              const SizedBox(width: 8),
              // スクロール可能なグリッド部分
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 月ラベル
                      _buildMonthLabels(startDate),
                      const SizedBox(height: 4),
                      // ヒートマップグリッド
                      _buildHeatmapGrid(startDate, today),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 凡例
        _buildLegend(),
        const SizedBox(height: 8),
        // スクロールヒント
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swipe, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                '← 左右にスクロールできます →',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthLabels(DateTime startDate) {
    final months = <Widget>[];
    int? lastMonth;
    double accumulatedWidth = 0;

    for (int week = 0; week < widget.weeksToShow; week++) {
      final weekStart = startDate.add(Duration(days: week * 7));
      if (lastMonth != weekStart.month) {
        if (months.isNotEmpty) {
          // 前の月との間隔を調整
          final gap = week *
                  (CalendarHeatmap.cellSize + CalendarHeatmap.cellMargin * 2) -
              accumulatedWidth;
          if (gap > 0) {
            months.add(SizedBox(width: gap));
            accumulatedWidth += gap;
          }
        }
        months.add(
          Text(
            _getMonthName(weekStart.month),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        );
        accumulatedWidth += 40; // 月名の幅の概算
        lastMonth = weekStart.month;
      }
    }

    return SizedBox(
      height: 20,
      child: Row(children: months),
    );
  }

  Widget _buildWeekdayLabels() {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return Padding(
      padding: const EdgeInsets.only(top: 24), // 月ラベル分のオフセット
      child: Column(
        children: List.generate(7, (index) {
          return Container(
            height: CalendarHeatmap.cellSize + CalendarHeatmap.cellMargin * 2,
            width: 24,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              weekdays[index],
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeatmapGrid(DateTime startDate, DateTime today) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.weeksToShow, (weekIndex) {
        return Column(
          children: List.generate(7, (dayIndex) {
            final date =
                startDate.add(Duration(days: weekIndex * 7 + dayIndex));
            final calories = _getCaloriesForDate(date);
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final isFuture = date.isAfter(today);

            return GestureDetector(
              onTap: isFuture ? null : () => widget.onDayTap?.call(date),
              child: Container(
                width: CalendarHeatmap.cellSize,
                height: CalendarHeatmap.cellSize,
                margin: EdgeInsets.all(CalendarHeatmap.cellMargin),
                decoration: BoxDecoration(
                  color: isFuture
                      ? Colors.transparent
                      : AppTheme.getHeatmapColor(calories),
                  borderRadius:
                      BorderRadius.circular(CalendarHeatmap.cellRadius),
                  border: isToday
                      ? Border.all(color: AppTheme.todayBorderColor, width: 1.5)
                      : null,
                  boxShadow: !isFuture && calories > 0
                      ? [
                          BoxShadow(
                            color: AppTheme.getHeatmapColor(calories)
                                .withValues(alpha: 0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: isToday
                    ? const Center(
                        child: Text(
                          '',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '少ない',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 8),
        _legendBox(AppTheme.grayLight),
        _legendBox(AppTheme.lightGreen1),
        _legendBox(AppTheme.lightGreen2),
        _legendBox(AppTheme.lightGreen3),
        _legendBox(AppTheme.darkGreen),
        const SizedBox(width: 8),
        const Text(
          '多い',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  int _getCaloriesForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return widget.data[normalizedDate] ?? 0;
  }

  String _getMonthName(int month) {
    const months = [
      '',
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月'
    ];
    return months[month];
  }
}
