// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppBadgeAdapter extends TypeAdapter<AppBadge> {
  @override
  final int typeId = 4;

  @override
  AppBadge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppBadge(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as BadgeType,
      threshold: fields[3] as int,
      isUnlocked: fields[4] as bool,
      unlockedAt: fields[5] as DateTime?,
      description: fields[6] as String,
      icon: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppBadge obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.threshold)
      ..writeByte(4)
      ..write(obj.isUnlocked)
      ..writeByte(5)
      ..write(obj.unlockedAt)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppBadgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeTypeAdapter extends TypeAdapter<BadgeType> {
  @override
  final int typeId = 5;

  @override
  BadgeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BadgeType.calories;
      case 1:
        return BadgeType.streak;
      case 2:
        return BadgeType.count;
      default:
        return BadgeType.calories;
    }
  }

  @override
  void write(BinaryWriter writer, BadgeType obj) {
    switch (obj) {
      case BadgeType.calories:
        writer.writeByte(0);
        break;
      case BadgeType.streak:
        writer.writeByte(1);
        break;
      case BadgeType.count:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
