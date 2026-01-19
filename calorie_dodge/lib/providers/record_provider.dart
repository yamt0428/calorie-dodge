import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/record.dart';
import '../services/storage_service.dart';

class RecordProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<CalorieRecord> _records = [];
  final _uuid = const Uuid();

  RecordProvider(this._storageService) {
    _loadRecords();
  }

  List<CalorieRecord> get records => _records;

  int get todayCalories {
    final today = DateTime.now();
    return _records
        .where((r) =>
            r.timestamp.year == today.year &&
            r.timestamp.month == today.month &&
            r.timestamp.day == today.day)
        .fold(0, (sum, r) => sum + r.calories);
  }

  int get totalCalories => _records.fold(0, (sum, r) => sum + r.calories);

  int get recordCount => _records.length;

  int get currentStreak => _storageService.getCurrentStreak();

  int get maxStreak => _storageService.getMaxStreak();

  void _loadRecords() {
    _records = _storageService.getAllRecords();
    notifyListeners();
  }

  Future<void> addRecord({
    required int calories,
    String? memo,
    DateTime? timestamp,
  }) async {
    final now = DateTime.now();
    final record = CalorieRecord(
      id: _uuid.v4(),
      calories: calories,
      memo: memo,
      timestamp: timestamp ?? now,
      createdAt: now,
      updatedAt: now,
    );

    await _storageService.addRecord(record);
    _loadRecords();
  }

  Future<void> updateRecord(CalorieRecord record) async {
    final updatedRecord = record.copyWith(updatedAt: DateTime.now());
    await _storageService.updateRecord(updatedRecord);
    _loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    await _storageService.deleteRecord(id);
    _loadRecords();
  }

  List<CalorieRecord> getRecordsForDate(DateTime date) {
    return _records.where((r) =>
        r.timestamp.year == date.year &&
        r.timestamp.month == date.month &&
        r.timestamp.day == date.day).toList();
  }

  /// 日付ごとのカロリー合計を取得
  Map<DateTime, int> getDailyCalories() {
    final dailyCalories = <DateTime, int>{};
    for (final record in _records) {
      final date = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      dailyCalories[date] = (dailyCalories[date] ?? 0) + record.calories;
    }
    return dailyCalories;
  }

  /// 週別のカロリー合計を取得
  Map<DateTime, int> getWeeklyCalories() {
    final weeklyCalories = <DateTime, int>{};
    for (final record in _records) {
      // 週の開始日（月曜日）を計算
      final weekStart = record.timestamp.subtract(
        Duration(days: record.timestamp.weekday - 1),
      );
      final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
      weeklyCalories[weekStartDate] = (weeklyCalories[weekStartDate] ?? 0) + record.calories;
    }
    return weeklyCalories;
  }

  /// 月別のカロリー合計を取得
  Map<DateTime, int> getMonthlyCalories() {
    final monthlyCalories = <DateTime, int>{};
    for (final record in _records) {
      final monthStart = DateTime(record.timestamp.year, record.timestamp.month, 1);
      monthlyCalories[monthStart] = (monthlyCalories[monthStart] ?? 0) + record.calories;
    }
    return monthlyCalories;
  }

  /// 統計情報を取得
  Map<String, dynamic> getStatistics() {
    return {
      'totalCalories': totalCalories,
      'recordCount': recordCount,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'mostActiveTimeOfDay': _storageService.getMostActiveTimeOfDay(),
      'maxDailyCalories': _storageService.getMaxDailyCalories(),
      'averageCaloriesPerRecord': _storageService.getAverageCaloriesPerRecord(),
      'averageCaloriesPerDay': _storageService.getAverageCaloriesPerDay(),
    };
  }
}
