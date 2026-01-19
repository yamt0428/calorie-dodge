// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalorieRecordAdapter extends TypeAdapter<CalorieRecord> {
  @override
  final int typeId = 0;

  @override
  CalorieRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalorieRecord(
      id: fields[0] as String,
      calories: fields[1] as int,
      memo: fields[2] as String?,
      timestamp: fields[3] as DateTime,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CalorieRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.memo)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalorieRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
