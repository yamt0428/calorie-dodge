// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 1;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      type: fields[1] as GoalType,
      targetValue: fields[2] as int,
      period: fields[3] as GoalPeriod,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.targetValue)
      ..writeByte(3)
      ..write(obj.period)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 2;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.period;
      case 1:
        return GoalType.streak;
      default:
        return GoalType.period;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.period:
        writer.writeByte(0);
        break;
      case GoalType.streak:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalPeriodAdapter extends TypeAdapter<GoalPeriod> {
  @override
  final int typeId = 3;

  @override
  GoalPeriod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalPeriod.weekly;
      case 1:
        return GoalPeriod.monthly;
      default:
        return GoalPeriod.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, GoalPeriod obj) {
    switch (obj) {
      case GoalPeriod.weekly:
        writer.writeByte(0);
        break;
      case GoalPeriod.monthly:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
