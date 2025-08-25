// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BinaryHabitAdapter extends TypeAdapter<BinaryHabit> {
  @override
  final int typeId = 2;

  @override
  BinaryHabit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BinaryHabit(
      id: fields[0] as String,
      name: fields[1] as String,
      colorValue: fields[2] as int,
      frequency: fields[3] as Frequency,
      frequencyCount: fields[4] as int,
      isArchived: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BinaryHabit obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.frequencyCount)
      ..writeByte(7)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinaryHabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuantitativeIncreasingHabitAdapter
    extends TypeAdapter<QuantitativeIncreasingHabit> {
  @override
  final int typeId = 3;

  @override
  QuantitativeIncreasingHabit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuantitativeIncreasingHabit(
      id: fields[0] as String,
      name: fields[1] as String,
      colorValue: fields[2] as int,
      frequency: fields[3] as Frequency,
      frequencyCount: fields[4] as int,
      goal: fields[5] as double,
      unit: fields[6] as String,
      isArchived: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QuantitativeIncreasingHabit obj) {
    writer
      ..writeByte(8)
      ..writeByte(5)
      ..write(obj.goal)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.frequencyCount)
      ..writeByte(7)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuantitativeIncreasingHabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuantitativeDecreasingHabitAdapter
    extends TypeAdapter<QuantitativeDecreasingHabit> {
  @override
  final int typeId = 4;

  @override
  QuantitativeDecreasingHabit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuantitativeDecreasingHabit(
      id: fields[0] as String,
      name: fields[1] as String,
      colorValue: fields[2] as int,
      frequency: fields[3] as Frequency,
      frequencyCount: fields[4] as int,
      limit: fields[5] as double,
      unit: fields[6] as String,
      isArchived: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QuantitativeDecreasingHabit obj) {
    writer
      ..writeByte(8)
      ..writeByte(5)
      ..write(obj.limit)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.frequencyCount)
      ..writeByte(7)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuantitativeDecreasingHabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FrequencyAdapter extends TypeAdapter<Frequency> {
  @override
  final int typeId = 1;

  @override
  Frequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Frequency.daily;
      case 1:
        return Frequency.weekly;
      case 2:
        return Frequency.monthly;
      default:
        return Frequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, Frequency obj) {
    switch (obj) {
      case Frequency.daily:
        writer.writeByte(0);
        break;
      case Frequency.weekly:
        writer.writeByte(1);
        break;
      case Frequency.monthly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
