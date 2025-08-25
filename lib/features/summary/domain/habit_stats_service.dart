import 'package:bitbithabit/features/habits/data/models/habit.dart';
import 'package:bitbithabit/features/habits/data/models/habit_log.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class HabitStatsService {
  final List<HabitLog> allLogs;
  final Habit habit;

  HabitStatsService({required this.allLogs, required this.habit}) {
    // Pastikan log selalu terurut dari terbaru ke terlama
    allLogs.sort((a, b) => b.date.compareTo(a.date));
  }

  // Helper utama untuk mengecek apakah sebuah log dianggap berhasil
  bool _isLogSuccessful(HabitLog? log) {
    if (log == null || log.status != LogStatus.completed) return false;
    
    if (habit is QuantitativeIncreasingHabit) {
      return (log.value ?? 0) >= (habit as QuantitativeIncreasingHabit).goal;
    }
    // Untuk Binary dan Decreasing, status 'completed' sudah cukup
    return true;
  }

  // STATISTIK KESELURUHAN & SAAT INI

  // 1. Menghitung Rangkaian Saat Ini (Current Streak)
  int calculateCurrentStreak() {
    if (allLogs.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();
    // Mulai pengecekan dari hari ini
    var dateToCheck = DateTime(now.year, now.month, now.day);

    // Looping mundur dari hari ini
    while (true) {
      final log = allLogs.firstWhereOrNull((l) => DateUtils.isSameDay(l.date, dateToCheck));
      
      // Jika hari yang dicek berhasil, tambah streak dan mundur satu hari
      if (_isLogSuccessful(log)) {
        streak++;
        dateToCheck = dateToCheck.subtract(const Duration(days: 1));
      } else {
        // Jika hari yang dicek tidak berhasil (gagal, skip, atau kosong),
        // rangkaian langsung terputus.
        break;
      }
    }
    return streak;
  }

  // 2. Menghitung Rangkaian Tertinggi (Highest Streak)
  int calculateHighestStreak() {
    if (allLogs.isEmpty) return 0;

    int highestStreak = 0;
    int currentStreak = 0;

    // Urutkan dari yang terlama ke terbaru untuk perhitungan yang lebih mudah
    final sortedLogs = List<HabitLog>.from(allLogs)..sort((a, b) => a.date.compareTo(b.date));
    
    for (int i = 0; i < sortedLogs.length; i++) {
      if (_isLogSuccessful(sortedLogs[i])) {
        // Jika ini log pertama atau merupakan hari setelah log sebelumnya
        if (i == 0 || !DateUtils.isSameDay(sortedLogs[i].date, sortedLogs[i-1].date.add(const Duration(days: 1)))) {
           currentStreak = 1;
        } else {
           currentStreak++;
        }
      } else {
        currentStreak = 0;
      }
      if (currentStreak > highestStreak) {
        highestStreak = currentStreak;
      }
    }
    return highestStreak;
  }

  // 3. Menghitung Performa Penyelesaian
  double calculateOverallPerformance() {
    // Hanya hitung log yang statusnya 'completed' atau 'failed'
    final performanceLogs = allLogs.where((log) => log.status == LogStatus.completed || log.status == LogStatus.failed).toList();
    if (performanceLogs.isEmpty) return 0.0;
    
    final successfulCount = performanceLogs.where((log) => _isLogSuccessful(log)).length;
    return (successfulCount / performanceLogs.length) * 100;
  }

  // STATISTIK BULANAN

  // 4. Menghitung Rangkaian di Bulan Tertentu
  int calculateMonthlyStreak(DateTime month) {
    final monthlyLogs = allLogs.where((log) => log.date.month == month.month && log.date.year == month.year).toList();
    if (monthlyLogs.isEmpty) return 0;

    int highestMonthlyStreak = 0;
    int currentMonthlyStreak = 0;
    
    // Urutkan dari yang terlama ke terbaru
    monthlyLogs.sort((a, b) => a.date.compareTo(b.date));

    for (int i = 0; i < monthlyLogs.length; i++) {
      if (_isLogSuccessful(monthlyLogs[i])) {
        if (i == 0 || !DateUtils.isSameDay(monthlyLogs[i].date, monthlyLogs[i-1].date.add(const Duration(days: 1)))) {
           currentMonthlyStreak = 1;
        } else {
           currentMonthlyStreak++;
        }
      } else {
        currentMonthlyStreak = 0;
      }
      if (currentMonthlyStreak > highestMonthlyStreak) {
        highestMonthlyStreak = currentMonthlyStreak;
      }
    }
    return highestMonthlyStreak;
  }

  // 5. Menghitung Tingkat Penyelesaian Bulanan
  Map<String, double> getStatsForMonth(DateTime month) {
    final monthlyLogs = allLogs.where((log) => log.date.month == month.month && log.date.year == month.year).toList();
    if (monthlyLogs.isEmpty) {
      return {'completionRate': 0.0};
    }
    
    final successfulCount = monthlyLogs.where((log) => _isLogSuccessful(log)).length;
    // Hitung persentase dari total hari di bulan itu
    final totalDaysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final completionRate = (successfulCount / totalDaysInMonth) * 100;
    
    return {'completionRate': completionRate};
  }
}