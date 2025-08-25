// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitLogAdapter extends TypeAdapter<HabitLog> {
  @override
  final int typeId = 11;

  @override
  HabitLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitLog(
      id: fields[0] as String,
      habitId: fields[1] as String,
      date: fields[2] as DateTime,
      status: fields[3] as LogStatus,
      value: fields[4] as double?,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LogStatusAdapter extends TypeAdapter<LogStatus> {
  @override
  final int typeId = 10;

  @override
  LogStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LogStatus.completed;
      case 1:
        return LogStatus.skipped;
      case 2:
        return LogStatus.failed;
      default:
        return LogStatus.completed;
    }
  }

  @override
  void write(BinaryWriter writer, LogStatus obj) {
    switch (obj) {
      case LogStatus.completed:
        writer.writeByte(0);
        break;
      case LogStatus.skipped:
        writer.writeByte(1);
        break;
      case LogStatus.failed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
