import 'package:hive/hive.dart';

part 'habit_log.g.dart'; // File ini akan kita generate

@HiveType(typeId: 10) // Gunakan ID yang belum terpakai
enum LogStatus {
  @HiveField(0)
  completed,

  @HiveField(1)
  skipped,

  @HiveField(2)
  failed,
}

@HiveType(typeId: 11)
class HabitLog extends HiveObject {
  // Kita gunakan composite key sebagai ID: "habitId-yyyy-mm-dd"
  @HiveField(0)
  String id;

  @HiveField(1)
  String habitId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  LogStatus status;

  @HiveField(4)
  double? value; // Untuk habit kuantitatif

  @HiveField(5)
  String? note; // Catatan atau alasan skip

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.status,
    this.value,
    this.note,
  });
}