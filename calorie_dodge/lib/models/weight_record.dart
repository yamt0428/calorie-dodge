import 'package:hive/hive.dart';

part 'weight_record.g.dart';

@HiveType(typeId: 6)
class WeightRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double weight; // 体重 (kg)

  @HiveField(2)
  double? bodyFatPercentage; // 体脂肪率 (%) - 任意

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  WeightRecord({
    required this.id,
    required this.weight,
    this.bodyFatPercentage,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  WeightRecord copyWith({
    String? id,
    double? weight,
    double? bodyFatPercentage,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 7)
class WeightGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double targetWeight; // 目標体重 (kg)

  @HiveField(2)
  double? targetBodyFatPercentage; // 目標体脂肪率 (%) - 任意

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  WeightGoal({
    required this.id,
    required this.targetWeight,
    this.targetBodyFatPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  WeightGoal copyWith({
    String? id,
    double? targetWeight,
    double? targetBodyFatPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightGoal(
      id: id ?? this.id,
      targetWeight: targetWeight ?? this.targetWeight,
      targetBodyFatPercentage: targetBodyFatPercentage ?? this.targetBodyFatPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
