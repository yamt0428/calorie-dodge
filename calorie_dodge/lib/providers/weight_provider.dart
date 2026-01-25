import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/weight_record.dart';
import '../services/storage_service.dart';

class WeightProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<WeightRecord> _records = [];
  WeightGoal? _goal;
  final _uuid = const Uuid();

  WeightProvider(this._storageService) {
    _loadData();
  }

  List<WeightRecord> get records => _records;
  WeightGoal? get goal => _goal;

  WeightRecord? get latestRecord => _records.isNotEmpty ? _records.first : null;

  double? get latestWeight => latestRecord?.weight;
  double? get latestBodyFat => latestRecord?.bodyFatPercentage;

  void _loadData() {
    _records = _storageService.getAllWeightRecords();
    _goal = _storageService.getWeightGoal();
    notifyListeners();
  }

  Future<void> addRecord({
    required double weight,
    double? bodyFatPercentage,
    DateTime? timestamp,
  }) async {
    final now = DateTime.now();
    final record = WeightRecord(
      id: _uuid.v4(),
      weight: weight,
      bodyFatPercentage: bodyFatPercentage,
      timestamp: timestamp ?? now,
      createdAt: now,
      updatedAt: now,
    );

    await _storageService.addWeightRecord(record);
    _loadData();
  }

  Future<void> updateRecord(WeightRecord record) async {
    final updatedRecord = record.copyWith(updatedAt: DateTime.now());
    await _storageService.updateWeightRecord(updatedRecord);
    _loadData();
  }

  Future<void> deleteRecord(String id) async {
    await _storageService.deleteWeightRecord(id);
    _loadData();
  }

  Future<void> setGoal({
    required double targetWeight,
    double? targetBodyFatPercentage,
  }) async {
    final now = DateTime.now();
    final goal = WeightGoal(
      id: _uuid.v4(),
      targetWeight: targetWeight,
      targetBodyFatPercentage: targetBodyFatPercentage,
      createdAt: now,
      updatedAt: now,
    );

    await _storageService.setWeightGoal(goal);
    _loadData();
  }

  Future<void> deleteGoal() async {
    await _storageService.deleteWeightGoal();
    _loadData();
  }

  /// 日別の体重データを取得
  Map<DateTime, double> getDailyWeights() {
    final dailyWeights = <DateTime, double>{};
    for (final record in _records) {
      final date = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      // 同じ日の最新の記録を使用
      if (!dailyWeights.containsKey(date)) {
        dailyWeights[date] = record.weight;
      }
    }
    return dailyWeights;
  }

  /// 日別の体脂肪率データを取得
  Map<DateTime, double> getDailyBodyFat() {
    final dailyBodyFat = <DateTime, double>{};
    for (final record in _records) {
      if (record.bodyFatPercentage != null) {
        final date = DateTime(
          record.timestamp.year,
          record.timestamp.month,
          record.timestamp.day,
        );
        // 同じ日の最新の記録を使用
        if (!dailyBodyFat.containsKey(date)) {
          dailyBodyFat[date] = record.bodyFatPercentage!;
        }
      }
    }
    return dailyBodyFat;
  }

  /// 週別の平均体重を取得
  Map<DateTime, double> getWeeklyWeights() {
    final weeklyData = <DateTime, List<double>>{};
    for (final record in _records) {
      // 週の開始日（月曜日）を計算
      final weekStart = record.timestamp.subtract(
        Duration(days: record.timestamp.weekday - 1),
      );
      final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
      weeklyData.putIfAbsent(weekStartDate, () => []).add(record.weight);
    }
    
    return weeklyData.map((key, values) => 
      MapEntry(key, values.reduce((a, b) => a + b) / values.length));
  }

  /// 週別の平均体脂肪率を取得
  Map<DateTime, double> getWeeklyBodyFat() {
    final weeklyData = <DateTime, List<double>>{};
    for (final record in _records) {
      if (record.bodyFatPercentage != null) {
        final weekStart = record.timestamp.subtract(
          Duration(days: record.timestamp.weekday - 1),
        );
        final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        weeklyData.putIfAbsent(weekStartDate, () => []).add(record.bodyFatPercentage!);
      }
    }
    
    return weeklyData.map((key, values) => 
      MapEntry(key, values.reduce((a, b) => a + b) / values.length));
  }

  /// 月別の平均体重を取得
  Map<DateTime, double> getMonthlyWeights() {
    final monthlyData = <DateTime, List<double>>{};
    for (final record in _records) {
      final monthStart = DateTime(record.timestamp.year, record.timestamp.month, 1);
      monthlyData.putIfAbsent(monthStart, () => []).add(record.weight);
    }
    
    return monthlyData.map((key, values) => 
      MapEntry(key, values.reduce((a, b) => a + b) / values.length));
  }

  /// 月別の平均体脂肪率を取得
  Map<DateTime, double> getMonthlyBodyFat() {
    final monthlyData = <DateTime, List<double>>{};
    for (final record in _records) {
      if (record.bodyFatPercentage != null) {
        final monthStart = DateTime(record.timestamp.year, record.timestamp.month, 1);
        monthlyData.putIfAbsent(monthStart, () => []).add(record.bodyFatPercentage!);
      }
    }
    
    return monthlyData.map((key, values) => 
      MapEntry(key, values.reduce((a, b) => a + b) / values.length));
  }

  /// 目標との差分を計算
  double? getWeightDifference() {
    if (_goal == null || latestWeight == null) return null;
    return latestWeight! - _goal!.targetWeight;
  }

  double? getBodyFatDifference() {
    if (_goal?.targetBodyFatPercentage == null || latestBodyFat == null) return null;
    return latestBodyFat! - _goal!.targetBodyFatPercentage!;
  }
}
