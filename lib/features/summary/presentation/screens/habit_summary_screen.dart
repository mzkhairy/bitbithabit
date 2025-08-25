import 'package:bitbithabit/features/habits/data/models/habit.dart';
import 'package:bitbithabit/features/habits/data/models/habit_log.dart';
import 'package:bitbithabit/features/habits/domain/habit_provider.dart';
import 'package:bitbithabit/features/summary/domain/habit_stats_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class HabitSummaryScreen extends ConsumerStatefulWidget {
  final String habitId;
  const HabitSummaryScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitSummaryScreen> createState() => _HabitSummaryScreenState();
}

class _HabitSummaryScreenState extends ConsumerState<HabitSummaryScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth = DateUtils.addMonthsToMonthDate(_selectedMonth, months);
    });
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2024),
      lastDate: DateTime(now.year + 5),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitProvider);
    final Habit? habit = habitState.habits.where((h) => h.id == widget.habitId).isNotEmpty
        ? habitState.habits.firstWhere((h) => h.id == widget.habitId)
        : null;
    final habitLogs = habitState.logs.values.where((log) => log.habitId == widget.habitId).toList();
    
    if (habit == null) {
      return const Scaffold(body: Center(child: Text("Habit tidak ditemukan.")));
    }
    
    final statsService = HabitStatsService(allLogs: habitLogs, habit: habit);
    // Hitung semua statistik
    final currentStreak = statsService.calculateCurrentStreak();
    final highestStreak = statsService.calculateHighestStreak();
    final performance = statsService.calculateOverallPerformance();
    final monthlyStreak = statsService.calculateMonthlyStreak(_selectedMonth);
    final monthlyCompletion = statsService.getStatsForMonth(_selectedMonth)['completionRate']!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name, style: TextStyle(color: habit.color, fontWeight: FontWeight.bold)),
        backgroundColor: habit.color.withOpacity(0.1),
        elevation: 0,
        actions: [
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: TextButton(
              style: TextButton.styleFrom(
              backgroundColor: habit.color.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
              context.go('/habit/${habit.id}');
              },
              child: const Text(
              'Edit Habit',
              style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- BAGIAN STATISTIK KESELURUHAN ---
          _buildSectionTitle('Statistik Keseluruhan'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildStatRow('Streak Saat Ini', '$currentStreak hari'),
                _buildStatRow('Streak Tertinggi', '$highestStreak hari'),
                _buildStatRow('Performa Penyelesaian', '${performance.toStringAsFixed(0)}% berhasil'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- BAGIAN STATISTIK BULANAN ---
          _buildSectionTitle('Statistik Bulanan'),
          // Navigasi Bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
              TextButton(
                onPressed: _pickMonth,
                child: Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeMonth(1)),
            ],
          ),
          const SizedBox(height: 8),
          // Statistik Bulanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Streak Bulan Ini', '$monthlyStreak', 'hari'),
              _buildStatCard('Penyelesaian', '${monthlyCompletion.toStringAsFixed(0)}%', 'bulan ini'),
            ],
          ),
          const SizedBox(height: 16),

          // Kalender Bulanan
          _buildMonthlyCalendarView(habitLogs, _selectedMonth, habit),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
  
  Widget _buildStatRow(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      dense: true,
    );
  }

  Widget _buildStatCard(String title, String value, String unit) {
    return Column(children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)), const SizedBox(height: 4), Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)), const SizedBox(width: 4), Text(unit, style: const TextStyle(color: Colors.grey))])]);
  }
  
  Widget _buildMonthlyCalendarView(List<HabitLog> logs, DateTime month, Habit habit) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDay = DateTime(month.year, month.month, 1);
    final dayOffset = firstDay.weekday - 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
      itemCount: daysInMonth + dayOffset,
      itemBuilder: (context, index) {
        if (index < dayOffset) return const SizedBox.shrink();

        final day = index - dayOffset + 1;
        final date = DateTime(month.year, month.month, day);
        final HabitLog? log = logs.where((l) => DateUtils.isSameDay(l.date, date)).isNotEmpty
            ? logs.firstWhere((l) => DateUtils.isSameDay(l.date, date))
            : null;

        return Container(
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
          child: _buildLogVisual(habit, log),
        );
      },
    );
  }

  Widget _buildLogVisual(Habit habit, HabitLog? log) {
    if (log == null) return const SizedBox.shrink();

    Color color = habit.color;
    Widget? overlayIcon;
    double opacity = 1.0;

    switch (log.status) {
      case LogStatus.completed:
        if (habit is QuantitativeIncreasingHabit) {
          final isSuccess = (log.value ?? 0) >= habit.goal;
          if (!isSuccess) return Container(decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)));
          final progress = (log.value ?? 0) / habit.goal;
          opacity = progress.clamp(0.15, 1.0);
          overlayIcon = const Icon(Icons.check, color: Colors.white, size: 16);
        } else if (habit is QuantitativeDecreasingHabit) {
          final progress = 1.0 - ((log.value ?? 0) / habit.limit);
          opacity = progress.clamp(0.15, 1.0);
          overlayIcon = const Icon(Icons.check, color: Colors.white, size: 16);
        } else {
          return Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)));
        }
        return Container(
          decoration: BoxDecoration(color: color.withOpacity(opacity), borderRadius: BorderRadius.circular(4)),
          child: overlayIcon != null ? Center(child: overlayIcon) : null,
        );

      case LogStatus.skipped:
        return Tooltip(message: log.note ?? "Dilewati", child: Icon(Icons.redo, color: Colors.grey.shade600, size: 16));
      
      case LogStatus.failed:
        return Container(
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
          child: const Center(child: Icon(Icons.close, color: Colors.white, size: 16)),
        );
    }
  }
}