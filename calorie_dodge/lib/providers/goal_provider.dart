import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';

class GoalProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Goal> _goals = [];
  final _uuid = const Uuid();

  GoalProvider(this._storageService) {
    _loadGoals();
  }

  List<Goal> get goals => _goals;

  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();

  void _loadGoals() {
    _goals = _storageService.getAllGoals();
    notifyListeners();
  }

  Future<void> addGoal({
    required GoalType type,
    required int targetValue,
    required GoalPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final goal = Goal(
      id: _uuid.v4(),
      type: type,
      targetValue: targetValue,
      period: period,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
    );

    await _storageService.addGoal(goal);
    _loadGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    await _storageService.updateGoal(goal);
    _loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _storageService.deleteGoal(id);
    _loadGoals();
  }

  Future<void> deactivateGoal(String id) async {
    final goal = _goals.firstWhere((g) => g.id == id);
    await _storageService.updateGoal(goal.copyWith(isActive: false));
    _loadGoals();
  }

  /// 目標の進捗率を計算
  double getGoalProgress(Goal goal, {
    required int currentCalories,
    required int currentStreak,
  }) {
    if (goal.type == GoalType.period) {
      return (currentCalories / goal.targetValue).clamp(0.0, 1.0);
    } else {
      return (currentStreak / goal.targetValue).clamp(0.0, 1.0);
    }
  }

  /// 期間内のカロリーを計算
  int getCaloriesInPeriod(Goal goal, List<dynamic> records) {
    final now = DateTime.now();
    DateTime periodStart;

    if (goal.period == GoalPeriod.weekly) {
      // 週の開始日（月曜日）
      periodStart = now.subtract(Duration(days: now.weekday - 1));
      periodStart = DateTime(periodStart.year, periodStart.month, periodStart.day);
    } else {
      // 月の開始日
      periodStart = DateTime(now.year, now.month, 1);
    }

    int total = 0;
    for (final record in records) {
      if (record.timestamp.isAfter(periodStart) ||
          (record.timestamp.year == periodStart.year &&
              record.timestamp.month == periodStart.month &&
              record.timestamp.day == periodStart.day)) {
        total += record.calories as int;
      }
    }
    return total;
  }

  /// 目標が達成されたかチェック
  bool isGoalAchieved(Goal goal, {
    required int currentCalories,
    required int currentStreak,
  }) {
    if (goal.type == GoalType.period) {
      return currentCalories >= goal.targetValue;
    } else {
      return currentStreak >= goal.targetValue;
    }
  }
}
