import 'package:bitbithabit/features/habits/data/models/habit.dart';
import 'package:bitbithabit/features/habits/domain/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

enum HabitType { binary, increasing, decreasing }

class AddEditHabitScreen extends ConsumerStatefulWidget {
  final String? habitId;
  const AddEditHabitScreen({super.key, this.habitId});

  @override
  ConsumerState<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends ConsumerState<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  final _limitController = TextEditingController();
  final _unitController = TextEditingController();

  Habit? _existingHabit;
  bool get _isEditing => widget.habitId != null;

  HabitType _selectedType = HabitType.binary;
  Color _selectedColor = Colors.blue;
  Frequency _selectedFrequency = Frequency.daily;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExistingHabitData();
    }
  }

  void _loadExistingHabitData() {
    final habit = ref.read(habitProvider).habits.firstWhere((h) => h.id == widget.habitId);
    _existingHabit = habit;

    _nameController.text = habit.name;
    _selectedColor = habit.color;
    _selectedFrequency = habit.frequency;

    if (habit is BinaryHabit) _selectedType = HabitType.binary;
    if (habit is QuantitativeIncreasingHabit) {
      _selectedType = HabitType.increasing;
      _goalController.text = habit.goal.toStringAsFixed(0);
      _unitController.text = habit.unit;
    }
    if (habit is QuantitativeDecreasingHabit) {
      _selectedType = HabitType.decreasing;
      _limitController.text = habit.limit.toStringAsFixed(0);
      _unitController.text = habit.unit;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _limitController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Warna Habit'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Pilih'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final habitNotifier = ref.read(habitProvider.notifier);
      
      final id = _isEditing ? _existingHabit!.id : const Uuid().v4();
      final name = _nameController.text;

      Habit newHabit;
      switch (_selectedType) {
        case HabitType.binary:
          newHabit = BinaryHabit(id: id, name: name, colorValue: _selectedColor.value, frequency: _selectedFrequency, isArchived: _existingHabit?.isArchived ?? false);
          break;
        case HabitType.increasing:
          newHabit = QuantitativeIncreasingHabit(id: id, name: name, colorValue: _selectedColor.value, frequency: _selectedFrequency, goal: double.parse(_goalController.text), unit: _unitController.text, isArchived: _existingHabit?.isArchived ?? false);
          break;
        case HabitType.decreasing:
          newHabit = QuantitativeDecreasingHabit(id: id, name: name, colorValue: _selectedColor.value, frequency: _selectedFrequency, limit: double.parse(_limitController.text), unit: _unitController.text, isArchived: _existingHabit?.isArchived ?? false);
          break;
      }

      habitNotifier.addHabit(newHabit);
      context.pop();
    }
  }

  void _archiveHabit() {
    if (!_isEditing) return;
    ref.read(habitProvider.notifier).archiveHabit(_existingHabit!.id);
    context.go('/');
  }

  void _deleteHabit() {
     if (!_isEditing) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus Habit?'),
          content: const Text('Aksi ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                 ref.read(habitProvider.notifier).deleteHabit(_existingHabit!.id);
                 context.go('/');
              },
            ),
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'Tambah Habit Baru'),
        actions: const [],
      ),
      // --- PERUBAHAN UTAMA DI SINI ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol Arsip & Hapus hanya muncul saat mode edit
            if (_isEditing) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Arsipkan'),
                  onPressed: _archiveHabit,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    backgroundColor: Colors.red.shade700
                  ),
                  onPressed: _deleteHabit,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Tombol Simpan Utama
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Habit'),
                onPressed: _saveHabit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        // Padding bawah ditambah agar tidak tertutup tumpukan FAB
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 220.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Habit', border: OutlineInputBorder(), hintText: 'Contoh: Olahraga Pagi'), validator: (value) => (value == null || value.isEmpty) ? 'Nama tidak boleh kosong' : null),
              const SizedBox(height: 20),
              Row(children: [const Text('Warna Habit', style: TextStyle(fontSize: 16)), const Spacer(), GestureDetector(onTap: _pickColor, child: Container(width: 40, height: 40, decoration: BoxDecoration(color: _selectedColor, shape: BoxShape.circle, border: Border.all(color: Colors.grey))))]),
              const SizedBox(height: 20),
              DropdownButtonFormField<HabitType>(value: _selectedType, decoration: const InputDecoration(labelText: 'Tipe Habit', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: HabitType.binary, child: Text('Binary (Berhasil jika dilakukan, gagal jika tidak)')), DropdownMenuItem(value: HabitType.increasing, child: Text('Kuantitatif (Berhasil jika mencapai target)')), DropdownMenuItem(value: HabitType.decreasing, child: Text('Kuantitatif (Berhasil jika dibawah batas maksimum)'))], onChanged: (value) => setState(() => _selectedType = value!)),
              const SizedBox(height: 20),
              if (_selectedType == HabitType.increasing) ...[TextFormField(controller: _goalController, decoration: const InputDecoration(labelText: 'Target', border: OutlineInputBorder(), hintText: 'Contoh: 5'), keyboardType: TextInputType.number, validator: (value) => (value == null || value.isEmpty) ? 'Target tidak boleh kosong' : null), const SizedBox(height: 20), TextFormField(controller: _unitController, decoration: const InputDecoration(labelText: 'Satuan', border: OutlineInputBorder(), hintText: 'Contoh: km, liter, halaman'), validator: (value) => (value == null || value.isEmpty) ? 'Satuan tidak boleh kosong' : null)],
              if (_selectedType == HabitType.decreasing) ...[TextFormField(controller: _limitController, decoration: const InputDecoration(labelText: 'Batas Maksimal', border: OutlineInputBorder(), hintText: 'Contoh: 3'), keyboardType: TextInputType.number, validator: (value) => (value == null || value.isEmpty) ? 'Batas tidak boleh kosong' : null), const SizedBox(height: 20), TextFormField(controller: _unitController, decoration: const InputDecoration(labelText: 'Satuan', border: OutlineInputBorder(), hintText: 'Contoh: batang, gelas, jam'), validator: (value) => (value == null || value.isEmpty) ? 'Satuan tidak boleh kosong' : null)],
            ],
          ),
        ),
      ),
    );
  }
}