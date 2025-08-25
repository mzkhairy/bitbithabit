import 'package:bitbithabit/features/habits/data/models/habit_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitbithabit/features/habits/data/models/habit.dart';
import 'package:bitbithabit/features/habits/data/repository.dart';

final habitRepositoryProvider = Provider((ref) => HabitRepository());

// Ubah StateNotifier kita untuk mengelola state yang lebih kompleks
final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return HabitNotifier(repository);
});

// Buat sebuah kelas untuk menampung semua state kita
class HabitState {
  final List<Habit> habits;
  final Map<String, HabitLog> logs; // Map<logId, HabitLog>

  const HabitState({this.habits = const [], this.logs = const {}});

  HabitState copyWith({
    List<Habit>? habits,
    Map<String, HabitLog>? logs,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      logs: logs ?? this.logs,
    );
  }
}

class HabitNotifier extends StateNotifier<HabitState> {
  final HabitRepository _repository;

  HabitNotifier(this._repository) : super(const HabitState()) {
    loadData();
  }

  // Fungsi untuk memuat semua data (habit dan log)
  Future<void> loadData() async {
    final habits = await _repository.getHabits();
    final logs = await _repository.getLogs();
    state = state.copyWith(habits: habits, logs: logs);
  }

  // --- CRUD untuk Habit ---
  Future<void> addHabit(Habit habit) async {
    await _repository.saveHabit(habit);
    await loadData();
  }

  Future<void> deleteHabit(String id) async {
    await _repository.deleteHabit(id);
    await loadData();
  }

  // --- FUNGSI BARU UNTUK LOG ---
  Future<void> updateLog(HabitLog log) async {
    await _repository.saveLog(log);
    // Perbarui state secara lokal agar lebih cepat, tanpa query ulang DB
    final newLogs = Map<String, HabitLog>.from(state.logs);
    newLogs[log.id] = log;
    state = state.copyWith(logs: newLogs);
  }

  Future<void> removeLog(String logId) async {
    await _repository.deleteLog(logId);
    final newLogs = Map<String, HabitLog>.from(state.logs);
    newLogs.remove(logId);
    state = state.copyWith(logs: newLogs);
  }

  Future<void> _toggleArchiveStatus(String habitId, bool archived) async {
    // Cari habit di state saat ini
    final habit = state.habits.firstWhere((h) => h.id == habitId);
    
    // Ubah status arsipnya
    habit.isArchived = archived;
    
    // Simpan kembali habit yang sudah diubah ke database
    await _repository.saveHabit(habit);
    
    // Muat ulang semua data untuk menyegarkan UI
    await loadData();
  }

  Future<void> archiveHabit(String habitId) async {
    await _toggleArchiveStatus(habitId, true);
  }
  
  Future<void> unarchiveHabit(String habitId) async {
    await _toggleArchiveStatus(habitId, false);
  }
}