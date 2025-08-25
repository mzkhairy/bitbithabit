import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/config/router.dart';
import 'app/config/theme.dart';
import 'features/habits/data/models/habit.dart';
import 'features/habits/data/models/habit_log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await initHive();
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

Future<void> initHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Hive tidak bisa mendaftarkan adapter yang sama dua kali.
  // Cek dulu sebelum mendaftarkan.
  if (!Hive.isAdapterRegistered(FrequencyAdapter().typeId)) {
    Hive.registerAdapter(FrequencyAdapter());
  }
  if (!Hive.isAdapterRegistered(BinaryHabitAdapter().typeId)) {
    Hive.registerAdapter(BinaryHabitAdapter());
  }
  if (!Hive.isAdapterRegistered(QuantitativeIncreasingHabitAdapter().typeId)) {
    Hive.registerAdapter(QuantitativeIncreasingHabitAdapter());
  }
  if (!Hive.isAdapterRegistered(QuantitativeDecreasingHabitAdapter().typeId)) {
    Hive.registerAdapter(QuantitativeDecreasingHabitAdapter());
  }
  if (!Hive.isAdapterRegistered(LogStatusAdapter().typeId)) {
    Hive.registerAdapter(LogStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(HabitLogAdapter().typeId)) {
    Hive.registerAdapter(HabitLogAdapter());
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan MaterialApp.router untuk mengaktifkan GoRouter
    return MaterialApp.router(
      title: 'bitbithabit: Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Otomatis sesuai tema sistem
      routerConfig: goRouter, // Gunakan konfigurasi router kita
    );
  }
}