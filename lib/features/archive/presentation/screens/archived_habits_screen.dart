// lib/features/archive/presentation/screens/archived_habits_screen.dart
import 'package:bitbithabit/features/habits/domain/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArchivedHabitsScreen extends ConsumerWidget {
  const ArchivedHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(habitProvider);
    // Filter untuk mendapatkan habit yang diarsip saja
    final archivedHabits = habitState.habits.where((h) => h.isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit yang Diarsipkan'),
      ),
      body: archivedHabits.isEmpty
          ? const Center(child: Text('Tidak ada habit yang diarsip.'))
          : ListView.builder(
              itemCount: archivedHabits.length,
              itemBuilder: (context, index) {
                final habit = archivedHabits[index];
                return ListTile(
                  leading: Icon(Icons.circle, color: habit.color),
                  title: Text(habit.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.unarchive_outlined),
                    tooltip: 'Aktifkan kembali',
                    onPressed: () {
                      // Panggil fungsi untuk mengaktifkan kembali
                      ref.read(habitProvider.notifier).unarchiveHabit(habit.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}