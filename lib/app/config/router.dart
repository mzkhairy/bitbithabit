import 'package:bitbithabit/features/habits/presentation/screens/add_edit_habit_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:bitbithabit/features/habits/presentation/screens/habit_tracker_screen.dart';
import 'package:bitbithabit/features/summary/presentation/screens/habit_summary_screen.dart';
import 'package:bitbithabit/features/archive/presentation/screens/archived_habits_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
  path: '/',
  builder: (context, state) => const HabitTrackerScreen(),
  routes: [
    // Rute ini sekarang bisa menangani edit juga (dengan parameter opsional)
        GoRoute(
          path: 'habit/:habitId',
          builder: (context, state) {
            final habitId = state.pathParameters['habitId'];
            // Jika habitId adalah 'new', berarti ini mode tambah
            // Jika bukan, berarti ini mode edit
            return AddEditHabitScreen(habitId: habitId == 'new' ? null : habitId);
          },
        ),
        GoRoute(
          path: 'summary/:habitId', // :habitId adalah parameter
          builder: (context, state) {
            // Ambil habitId dari parameter URL
            final habitId = state.pathParameters['habitId']!;
            return HabitSummaryScreen(habitId: habitId);
          },
        ),
        GoRoute(
         path: 'archived',
         builder: (context, state) => const ArchivedHabitsScreen(),
        ),
      ],
    ),
  ],
);