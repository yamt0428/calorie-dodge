import 'package:hive_flutter/hive_flutter.dart';
import '../models/record.dart';
import '../models/goal.dart';
import '../models/badge.dart';
import '../models/weight_record.dart';

class StorageService {
  static const String recordsBoxName = 'records';
  static const String goalsBoxName = 'goals';
  static const String badgesBoxName = 'badges';
  static const String settingsBoxName = 'settings';
  static const String weightRecordsBoxName = 'weight_records';
  static const String weightGoalsBoxName = 'weight_goals';

  late Box<CalorieRecord> _recordsBox;
  late Box<Goal> _goalsBox;
  late Box<AppBadge> _badgesBox;
  late Box<dynamic> _settingsBox;
  late Box<WeightRecord> _weightRecordsBox;
  late Box<WeightGoal> _weightGoalsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    // アダプター登録
    Hive.registerAdapter(CalorieRecordAdapter());
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(GoalTypeAdapter());
    Hive.registerAdapter(GoalPeriodAdapter());
    Hive.registerAdapter(AppBadgeAdapter());
    Hive.registerAdapter(BadgeTypeAdapter());
    Hive.registerAdapter(WeightRecordAdapter());
    Hive.registerAdapter(WeightGoalAdapter());

    // ボックスを開く
    _recordsBox = await Hive.openBox<CalorieRecord>(recordsBoxName);
    _goalsBox = await Hive.openBox<Goal>(goalsBoxName);
    _badgesBox = await Hive.openBox<AppBadge>(badgesBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    _weightRecordsBox = await Hive.openBox<WeightRecord>(weightRecordsBoxName);
    _weightGoalsBox = await Hive.openBox<WeightGoal>(weightGoalsBoxName);

    // 初期バッジをセットアップ
    await _initializeBadges();
  }

  Future<void> _initializeBadges() async {
    if (_badgesBox.isEmpty) {
      final badges = BadgeDefinitions.getAllBadges();
      for (final badge in badges) {
        await _badgesBox.put(badge.id, badge);
      }
    }
  }

  // === Records ===
  Box<CalorieRecord> get recordsBox => _recordsBox;

  List<CalorieRecord> getAllRecords() {
    return _recordsBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addRecord(CalorieRecord record) async {
    await _recordsBox.put(record.id, record);
  }

  Future<void> updateRecord(CalorieRecord record) async {
    await _recordsBox.put(record.id, record);
  }

  Future<void> deleteRecord(String id) async {
    await _recordsBox.delete(id);
  }

  List<CalorieRecord> getRecordsForDate(DateTime date) {
    return _recordsBox.values.where((record) {
      return record.timestamp.year == date.year &&
          record.timestamp.month == date.month &&
          record.timestamp.day == date.day;
    }).toList();
  }

  List<CalorieRecord> getRecordsInRange(DateTime start, DateTime end) {
    return _recordsBox.values.where((record) {
      return record.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
          record.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // === Goals ===
  Box<Goal> get goalsBox => _goalsBox;

  List<Goal> getAllGoals() {
    return _goalsBox.values.toList();
  }

  List<Goal> getActiveGoals() {
    return _goalsBox.values.where((goal) => goal.isActive).toList();
  }

  Future<void> addGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  Future<void> updateGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }

  // === Badges ===
  Box<AppBadge> get badgesBox => _badgesBox;

  List<AppBadge> getAllBadges() {
    return _badgesBox.values.toList();
  }

  List<AppBadge> getUnlockedBadges() {
    return _badgesBox.values.where((badge) => badge.isUnlocked).toList();
  }

  Future<void> unlockBadge(String id) async {
    final badge = _badgesBox.get(id);
    if (badge != null && !badge.isUnlocked) {
      badge.isUnlocked = true;
      badge.unlockedAt = DateTime.now();
      await badge.save();
    }
  }

  // === Settings ===
  Box<dynamic> get settingsBox => _settingsBox;

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  // === Statistics ===
  int getTotalCalories() {
    return _recordsBox.values.fold(0, (sum, record) => sum + record.calories);
  }

  int getTodayCalories() {
    final today = DateTime.now();
    return getRecordsForDate(today).fold(0, (sum, record) => sum + record.calories);
  }

  int getRecordCount() {
    return _recordsBox.length;
  }

  /// 連続記録日数を計算
  int getCurrentStreak() {
    if (_recordsBox.isEmpty) return 0;

    final records = getAllRecords();
    if (records.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 記録がある日付のセットを作成
    final recordedDates = <DateTime>{};
    for (final record in records) {
      recordedDates.add(DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      ));
    }

    int streak = 0;
    DateTime checkDate = today;

    // 今日の記録があるかチェック
    if (!recordedDates.contains(today)) {
      // 今日の記録がない場合、昨日からチェック
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (recordedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// 最長連続記録日数を取得
  int getMaxStreak() {
    if (_recordsBox.isEmpty) return 0;

    final records = getAllRecords();
    if (records.isEmpty) return 0;

    // 記録がある日付のリストを作成（ソート済み）
    final recordedDates = <DateTime>{};
    for (final record in records) {
      recordedDates.add(DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      ));
    }

    final sortedDates = recordedDates.toList()..sort();

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  /// 最も記録の多い時間帯を取得
  String getMostActiveTimeOfDay() {
    if (_recordsBox.isEmpty) return '-';

    final records = getAllRecords();
    int morning = 0;
    int afternoon = 0;
    int night = 0;

    for (final record in records) {
      switch (record.timeOfDay) {
        case '朝':
          morning++;
          break;
        case '昼':
          afternoon++;
          break;
        case '夜':
          night++;
          break;
      }
    }

    if (morning >= afternoon && morning >= night) {
      return '朝';
    } else if (afternoon >= morning && afternoon >= night) {
      return '昼';
    } else {
      return '夜';
    }
  }

  /// 1日の最大回避カロリー
  int getMaxDailyCalories() {
    if (_recordsBox.isEmpty) return 0;

    final records = getAllRecords();
    final dailyTotals = <DateTime, int>{};

    for (final record in records) {
      final date = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      dailyTotals[date] = (dailyTotals[date] ?? 0) + record.calories;
    }

    if (dailyTotals.isEmpty) return 0;
    return dailyTotals.values.reduce((a, b) => a > b ? a : b);
  }

  /// 平均回避カロリー（1回あたり）
  double getAverageCaloriesPerRecord() {
    if (_recordsBox.isEmpty) return 0;
    return getTotalCalories() / _recordsBox.length;
  }

  /// 平均回避カロリー（1日あたり）
  double getAverageCaloriesPerDay() {
    if (_recordsBox.isEmpty) return 0;

    final records = getAllRecords();
    final recordedDates = <DateTime>{};
    for (final record in records) {
      recordedDates.add(DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      ));
    }

    if (recordedDates.isEmpty) return 0;
    return getTotalCalories() / recordedDates.length;
  }

  // === Weight Records ===
  Box<WeightRecord> get weightRecordsBox => _weightRecordsBox;

  List<WeightRecord> getAllWeightRecords() {
    return _weightRecordsBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addWeightRecord(WeightRecord record) async {
    await _weightRecordsBox.put(record.id, record);
  }

  Future<void> updateWeightRecord(WeightRecord record) async {
    await _weightRecordsBox.put(record.id, record);
  }

  Future<void> deleteWeightRecord(String id) async {
    await _weightRecordsBox.delete(id);
  }

  WeightRecord? getLatestWeightRecord() {
    final records = getAllWeightRecords();
    return records.isNotEmpty ? records.first : null;
  }

  // === Weight Goals ===
  Box<WeightGoal> get weightGoalsBox => _weightGoalsBox;

  WeightGoal? getWeightGoal() {
    final goals = _weightGoalsBox.values.toList();
    return goals.isNotEmpty ? goals.first : null;
  }

  Future<void> setWeightGoal(WeightGoal goal) async {
    // 既存の目標を削除して新しい目標を設定
    await _weightGoalsBox.clear();
    await _weightGoalsBox.put(goal.id, goal);
  }

  Future<void> deleteWeightGoal() async {
    await _weightGoalsBox.clear();
  }
}
