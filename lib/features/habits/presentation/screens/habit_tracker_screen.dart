import 'package:bitbithabit/app/providers/date_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/habit_grid.dart';

class HabitTrackerScreen extends ConsumerWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bitbithabit'),
        // Menggunakan leading untuk tombol navigasi bulan
        leading: Consumer(
          builder: (context, ref, child) {
            // Tombol ini akan menggeser ke bulan sebelumnya
            return IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                // Hapus filter custom jika ada
                ref.read(dateRangeProvider.notifier).state = null;
                // Mundur satu bulan
                ref.read(displayedMonthProvider.notifier).update(
                  (state) => DateUtils.addMonthsToMonthDate(state, -1)
                );
              },
            );
          },
        ),
        // Menampilkan judul bulan/rentang yang dinamis
        actions: [
          // Widget ini akan membangun ulang dirinya sendiri saat state berubah
          Consumer(
            builder: (context, ref, child) {
              final range = ref.watch(dateRangeProvider);
              final month = ref.watch(displayedMonthProvider);

              String buttonText;
              // Logika untuk menentukan teks tombol
              if (range != null) {
                final start = DateFormat('MMM yyyy', 'id_ID').format(range.start);
                final end = DateFormat('MMM yyyy', 'id_ID').format(range.end);
                if (range.start.year == range.end.year) {
                   final startMonth = DateFormat('MMM', 'id_ID').format(range.start);
                   buttonText = '$startMonth - $end';
                } else {
                   buttonText = '$start - $end';
                }
              } else {
                buttonText = DateFormat('MMMM yyyy', 'id_ID').format(month);
              }

              return TextButton.icon(
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(buttonText),
                onPressed: () async {
                  final selectedRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now().add(const Duration(days: 365)), // Bisa melihat 1 thn ke depan
                  );
                  if (selectedRange != null) {
                    ref.read(dateRangeProvider.notifier).state = selectedRange;
                  }
                },
              );
            },
          ),
          // Tombol untuk maju ke bulan berikutnya
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  ref.read(dateRangeProvider.notifier).state = null;
                  ref.read(displayedMonthProvider.notifier).update(
                    (state) => DateUtils.addMonthsToMonthDate(state, 1)
                  );
                },
              );
            },
          ),
        ],
      ),
      body: const HabitGrid(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Tombol Tambah Habit di kiri
          FloatingActionButton.extended(
            onPressed: () => context.go('/habit/new'),
            label: const Text('Habit Baru'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
          
          // Tombol Pengaturan di kanan
          FloatingActionButton(
            onPressed: () {}, // Dibiarkan kosong karena aksi ditangani PopupMenuButton
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.settings),
              tooltip: 'Pengaturan',
              // Offset untuk memposisikan menu di atas tombol
              offset: const Offset(0, -90),
              onSelected: (value) {
                if (value == 'arsip') {
                  context.go('/archived');
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'arsip',
                  child: ListTile(
                    leading: Icon(Icons.archive_outlined),
                    title: Text('Lihat Arsip'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}