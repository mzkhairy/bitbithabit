import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Baris ini penting untuk memberitahu generator file mana yang harus dibuat
part 'habit.g.dart';

// --- ENUMS ---
@HiveType(typeId: 1)
enum Frequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly, // x kali per minggu
  @HiveField(2)
  monthly, // x kali per bulan
}


abstract class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  Frequency frequency;

  @HiveField(4)
  int frequencyCount;

  @HiveField(7) // Menandakan apakah habit ini diarsipkan
  bool isArchived;

  Habit({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.frequency,
    this.frequencyCount = 1,
    this.isArchived = false,
  });

  // Getter untuk mengubah nilai integer warna menjadi objek Color
  Color get color => Color(colorValue);
}


// --- CONCRETE CLASSES ---

// 1. Tipe Binary (Selesai / Tidak Selesai)
@HiveType(typeId: 2)
class BinaryHabit extends Habit {
  BinaryHabit({
    required super.id,
    required super.name,
    required super.colorValue,
    required super.frequency,
    super.frequencyCount,
    super.isArchived,
  });
}

// 2. Tipe Kuantitatif Bertambah (Mencapai Target)
@HiveType(typeId: 3)
class QuantitativeIncreasingHabit extends Habit {
  @HiveField(5)
  double goal;

  @HiveField(6)
  String unit;

  QuantitativeIncreasingHabit({
    required super.id,
    required super.name,
    required super.colorValue,
    required super.frequency,
    super.frequencyCount,
    required this.goal,
    required this.unit,
    super.isArchived,
  });
}

// 3. Tipe Kuantitatif Berkurang (Di Bawah Batas)
@HiveType(typeId: 4)
class QuantitativeDecreasingHabit extends Habit {
  @HiveField(5)
  double limit;

  @HiveField(6)
  String unit;

  QuantitativeDecreasingHabit({
    required super.id,
    required super.name,
    required super.colorValue,
    required super.frequency,
    super.frequencyCount,
    required this.limit,
    required this.unit,
    super.isArchived,
  });
}