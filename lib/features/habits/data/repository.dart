import 'package:bitbithabit/features/habits/data/models/habit_log.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/habit.dart';

class HabitRepository {
  static const String _habitBoxName = 'habits';
  static const String _logBoxName = 'habit_logs';

  // --- Fungsi untuk Habit ---
  Future<Box<Habit>> _openHabitBox() async => await Hive.openBox<Habit>(_habitBoxName);
  Future<List<Habit>> getHabits() async => (await _openHabitBox()).values.toList();
  Future<void> saveHabit(Habit habit) async => (await _openHabitBox()).put(habit.id, habit);
  Future<void> deleteHabit(String id) async => (await _openHabitBox()).delete(id);

  // --- FUNGSI BARU UNTUK LOG ---
  Future<Box<HabitLog>> _openLogBox() async => await Hive.openBox<HabitLog>(_logBoxName);

  // Mengambil semua log dan mengubahnya menjadi Map untuk pencarian cepat
  Future<Map<String, HabitLog>> getLogs() async {
    final box = await _openLogBox();
    return {for (var log in box.values) log.id: log};
  }

  // Menyimpan atau memperbarui satu log
  Future<void> saveLog(HabitLog log) async {
    final box = await _openLogBox();
    await box.put(log.id, log);
  }

  // Menghapus satu log
  Future<void> deleteLog(String logId) async {
    final box = await _openLogBox();
    await box.delete(logId);
  }
}