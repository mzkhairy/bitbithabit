import 'package:bitbithabit/app/providers/date_provider.dart';
import 'package:bitbithabit/features/habits/data/models/habit.dart';
import 'package:bitbithabit/features/habits/data/models/habit_log.dart';
import 'package:bitbithabit/features/habits/domain/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const double kHabitNameColumnWidth = 130.0;
const double kDateColumnWidth = 60.0;
const double kCellHeight = 55.0;
const double kHeaderHeight = 55.0;

class HabitGrid extends ConsumerStatefulWidget {
  const HabitGrid({super.key});

  @override
  ConsumerState<HabitGrid> createState() => _HabitGridState();
}

class _HabitGridState extends ConsumerState<HabitGrid> {
  final ScrollController _headerHorizontal = ScrollController();
  final ScrollController _bodyHorizontal = ScrollController();
  final ScrollController _bodyVertical = ScrollController();
  final ScrollController _habitNameVertical = ScrollController();

  List<DateTime> _dateRange = [];

  @override
  void initState() {
    super.initState();
    _headerHorizontal.addListener(_syncHorizontal);
    _bodyHorizontal.addListener(_syncHorizontal);
    _bodyVertical.addListener(_syncVertical);
    _habitNameVertical.addListener(_syncVertical);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _generateDateList(isInitialLoad: true);
  }

  void _generateDateList({bool isInitialLoad = false}) {
    final selectedRange = ref.read(dateRangeProvider);
    final displayedMonth = ref.read(displayedMonthProvider);
    
    DateTime startDate;
    DateTime endDate;

    if (selectedRange != null) {
      startDate = DateTime(selectedRange.start.year, selectedRange.start.month, selectedRange.start.day);
      endDate = DateTime(selectedRange.end.year, selectedRange.end.month, selectedRange.end.day);
    } else {
      startDate = DateTime(displayedMonth.year, displayedMonth.month, 1);
      endDate = DateTime(displayedMonth.year, displayedMonth.month, DateUtils.getDaysInMonth(displayedMonth.year, displayedMonth.month));
    }

    final days = endDate.difference(startDate).inDays;
    if (mounted) {
      setState(() {
        _dateRange = List.generate(days + 1, (i) => startDate.add(Duration(days: i)));
      });
    }
    
    if (isInitialLoad && selectedRange == null) {
        final now = DateTime.now();
        if(now.month == displayedMonth.month && now.year == displayedMonth.year){
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
        }
    }
  }

  void _scrollToToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayIndex = _dateRange.indexWhere((date) => date == today);

    if (todayIndex != -1 && _headerHorizontal.hasClients) {
      final targetOffset = (todayIndex * kDateColumnWidth) - (context.size!.width / 3);
      final maxScroll = _headerHorizontal.position.maxScrollExtent;
      final finalOffset = targetOffset.clamp(0.0, maxScroll);
      
      _headerHorizontal.animateTo(finalOffset, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
    }
  }

  void _syncHorizontal() {
    if (_headerHorizontal.hasClients && _bodyHorizontal.hasClients) {
      if (_headerHorizontal.position.isScrollingNotifier.value) {
        if (_bodyHorizontal.offset != _headerHorizontal.offset) _bodyHorizontal.jumpTo(_headerHorizontal.offset);
      } else if (_bodyHorizontal.position.isScrollingNotifier.value) {
        if (_headerHorizontal.offset != _bodyHorizontal.offset) _headerHorizontal.jumpTo(_bodyHorizontal.offset);
      }
    }
  }

  void _syncVertical() {
    if (_bodyVertical.hasClients && _habitNameVertical.hasClients) {
      if (_bodyVertical.position.isScrollingNotifier.value) {
        if (_habitNameVertical.offset != _bodyVertical.offset) _habitNameVertical.jumpTo(_bodyVertical.offset);
      } else if (_habitNameVertical.position.isScrollingNotifier.value) {
        if (_bodyVertical.offset != _habitNameVertical.offset) _bodyVertical.jumpTo(_bodyVertical.offset);
      }
    }
  }

  @override
  void dispose() {
    _headerHorizontal.removeListener(_syncHorizontal);
    _bodyHorizontal.removeListener(_syncHorizontal);
    _bodyVertical.removeListener(_syncVertical);
    _habitNameVertical.removeListener(_syncVertical);
    _headerHorizontal.dispose();
    _bodyHorizontal.dispose();
    _bodyVertical.dispose();
    _habitNameVertical.dispose();
    super.dispose();
  }

  String _getLogId(String habitId, DateTime date) => '$habitId-${date.year}-${date.month}-${date.day}';

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitProvider);
    // **PERBAIKAN UTAMA: FILTER HABIT YANG AKTIF SAJA**
    final List<Habit> activeHabits = habitState.habits.where((h) => !h.isArchived).toList();
    
    ref.listen(dateRangeProvider, (_, __) => _generateDateList());
    ref.listen(displayedMonthProvider, (_, __) => _generateDateList());

    if (activeHabits.isEmpty) {
      return const Center(child: Text('Tidak ada habit aktif.\nTekan + untuk memulai atau cek arsip.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)));
    }

    if (_dateRange.isEmpty) {
       return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildHeader(Theme.of(context)),
        const Divider(height: 1, thickness: 1.5),
        Expanded(child: _buildBody(activeHabits, habitState.logs, Theme.of(context))),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return SizedBox(
      height: kHeaderHeight,
      child: Row(
        children: [
          Container(width: kHabitNameColumnWidth, height: kHeaderHeight, alignment: Alignment.center, child: Text('Habit', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
          const VerticalDivider(width: 1.5, thickness: 1.5),
          Expanded(
            child: SingleChildScrollView(
              controller: _headerHorizontal,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                children: _dateRange.map((date) {
                  final isToday = DateUtils.isSameDay(date, DateTime.now());
                  return Container(
                    width: kDateColumnWidth,
                    height: kHeaderHeight,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: isToday ? BoxDecoration(border: Border(bottom: BorderSide(color: theme.primaryColor, width: 2.5))) : null,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('E', 'id_ID').format(date), style: theme.textTheme.bodySmall?.copyWith(fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                        const SizedBox(height: 4),
                        Text(DateFormat('dd/MM').format(date), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<Habit> habits, Map<String, HabitLog> logs, ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: kHabitNameColumnWidth,
          child: ListView.separated(
            controller: _habitNameVertical,
            physics: const ClampingScrollPhysics(),
            itemCount: habits.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return InkWell(
                onTap: () => context.go('/summary/${habit.id}'),
                child: Container(
                  height: kCellHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: habit.color, size: 12),
                      const SizedBox(width: 8),
                      Expanded(child: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1.5, thickness: 1.5),
        Expanded(
          child: SingleChildScrollView(
            controller: _bodyHorizontal,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: kDateColumnWidth * _dateRange.length,
              child: ListView.separated(
                controller: _bodyVertical,
                physics: const ClampingScrollPhysics(),
                itemCount: habits.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, habitIndex) {
                  final habit = habits[habitIndex];
                  return Row(
                    children: _dateRange.map((date) {
                      final logId = _getLogId(habit.id, date);
                      final log = logs[logId];
                      return _buildCell(context, habit, date, log);
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCell(BuildContext context, Habit habit, DateTime date, HabitLog? log) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cellDate = DateTime(date.year, date.month, date.day);
    
    final canInteract = !cellDate.isAfter(today);
    final isFuture = cellDate.isAfter(today);

    return InkWell(
      onTap: canInteract ? () => _showLogEntryDialog(context, habit, date, log) : null,
      child: Container(
        width: kDateColumnWidth,
        height: kCellHeight,
        decoration: BoxDecoration(
          color: isFuture ? Colors.grey.withOpacity(0.08) : Colors.transparent,
          border: Border(right: BorderSide(color: Colors.grey.shade200, width: 0.5)),
        ),
        child: _buildLogVisual(habit, log),
      ),
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
          final progress = (log.value ?? 0) / habit.goal;
          opacity = progress.clamp(0.15, 1.0);
          if (progress >= 1.0) overlayIcon = const Icon(Icons.check, color: Colors.white, size: 20);
        } else if (habit is QuantitativeDecreasingHabit) {
          final progress = 1.0 - ((log.value ?? 0) / habit.limit);
          opacity = progress.clamp(0.15, 1.0);
          overlayIcon = const Icon(Icons.check, color: Colors.white, size: 20);
        } else {
          overlayIcon = Icon(Icons.check, color: color);
        }
        return Stack(alignment: Alignment.center, children: [
          Container(color: (habit is BinaryHabit) ? Colors.transparent : color.withOpacity(opacity)),
          if (overlayIcon != null) overlayIcon,
        ]);

      case LogStatus.skipped:
        return Tooltip(message: log.note ?? "Dilewati", child: Icon(Icons.redo, color: Colors.grey.shade600, size: 18));
      
      case LogStatus.failed:
        return Container(color: Colors.red.withOpacity(0.7), child: const Icon(Icons.close, color: Colors.white, size: 20));
    }
  }

  void _showLogEntryDialog(BuildContext context, Habit habit, DateTime date, HabitLog? log) {
    showModalBottomSheet(
      context: context,
      // Membuat sheet bisa scroll dan ukurannya pas dengan keyboard
      isScrollControlled: true,
      // Menggunakan builder untuk membuat konten sheet
      builder: (context) {
        return _LogDialogSheet(habit: habit, date: date, log: log);
      },
    );
  }
}

class _LogDialogSheet extends ConsumerStatefulWidget {
  const _LogDialogSheet({required this.habit, required this.date, this.log});
  final Habit habit;
  final DateTime date;
  final HabitLog? log;

  @override
  ConsumerState<_LogDialogSheet> createState() => _LogDialogSheetState();
}

class _LogDialogSheetState extends ConsumerState<_LogDialogSheet> {
  late final TextEditingController _valueController;
  late final TextEditingController _reasonController;
  bool _canSkip = false;

  String get _logId => '${widget.habit.id}-${widget.date.year}-${widget.date.month}-${widget.date.day}';

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.log?.value?.toStringAsFixed(0) ?? '');
    _reasonController = TextEditingController(text: widget.log?.note ?? '');
    _canSkip = _reasonController.text.isNotEmpty;
    _reasonController.addListener(() => setState(() => _canSkip = _reasonController.text.trim().isNotEmpty));
  }
  
  @override
  void dispose() {
    _valueController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _save(LogStatus status, {double? value}) {
    ref.read(habitProvider.notifier).updateLog(HabitLog(id: _logId, habitId: widget.habit.id, date: widget.date, status: status, value: value, note: _reasonController.text));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    // Padding untuk memberi ruang saat keyboard muncul
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Text(habit.name, style: Theme.of(context).textTheme.headlineSmall),
          Text(DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(widget.date), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          
          // Form
          if (habit is QuantitativeIncreasingHabit)
            TextFormField(controller: _valueController, autofocus: true, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Progress (Target: ${habit.goal.toStringAsFixed(0)})', suffixText: habit.unit))
          else if (habit is QuantitativeDecreasingHabit)
            TextFormField(controller: _valueController, autofocus: true, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Jumlah (Batas: ${habit.limit.toStringAsFixed(0)})', suffixText: habit.unit))
          else
            const Text('Apakah habit ini sudah tercapai?'),
          const SizedBox(height: 16),
          TextFormField(controller: _reasonController, decoration: const InputDecoration(labelText: 'Alasan (jika dilewati)')),
          const SizedBox(height: 24),
          
          // Tombol Aksi
          Row(
            children: [
              if (widget.log != null)
                TextButton(onPressed: () { ref.read(habitProvider.notifier).removeLog(_logId); Navigator.of(context).pop(); }, child: const Text('Hapus', style: TextStyle(color: Colors.red))),
              const Spacer(),
              if (habit is BinaryHabit)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(onPressed: () => _save(LogStatus.failed), child: const Text('Tidak')),
                    TextButton(onPressed: _canSkip ? () => _save(LogStatus.skipped) : null, child: const Text('Lewati')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => _save(LogStatus.completed), child: const Text('Ya')),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(onPressed: _canSkip ? () => _save(LogStatus.skipped) : null, child: const Text('Lewati')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                          final value = double.tryParse(_valueController.text) ?? 0;
                          LogStatus status = LogStatus.completed;
                          if (habit is QuantitativeDecreasingHabit && value > habit.limit) {
                            status = LogStatus.failed;
                          }
                          _save(status, value: value);
                      }, 
                      child: const Text('Simpan'),
                    ),
                  ],
                )
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}