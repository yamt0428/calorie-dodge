import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 1)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  GoalType type;

  @HiveField(2)
  int targetValue;

  @HiveField(3)
  GoalPeriod period;

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime endDate;

  @HiveField(6)
  bool isActive;

  Goal({
    required this.id,
    required this.type,
    required this.targetValue,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  Goal copyWith({
    String? id,
    GoalType? type,
    int? targetValue,
    GoalPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Goal(
      id: id ?? this.id,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

@HiveType(typeId: 2)
enum GoalType {
  @HiveField(0)
  period, // 期間ベースの目標

  @HiveField(1)
  streak, // 連続記録の目標
}

@HiveType(typeId: 3)
enum GoalPeriod {
  @HiveField(0)
  weekly,

  @HiveField(1)
  monthly,
}
