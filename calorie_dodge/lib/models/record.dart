import 'package:hive/hive.dart';

part 'record.g.dart';

@HiveType(typeId: 0)
class CalorieRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int calories;

  @HiveField(2)
  String? memo;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  CalorieRecord({
    required this.id,
    required this.calories,
    this.memo,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  CalorieRecord copyWith({
    String? id,
    int? calories,
    String? memo,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalorieRecord(
      id: id ?? this.id,
      calories: calories ?? this.calories,
      memo: memo ?? this.memo,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 時間帯を取得（朝/昼/夜）
  String get timeOfDay {
    final hour = timestamp.hour;
    if (hour >= 5 && hour < 12) {
      return '朝';
    } else if (hour >= 12 && hour < 18) {
      return '昼';
    } else {
      return '夜';
    }
  }
}
