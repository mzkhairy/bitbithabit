import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider untuk menyimpan rentang tanggal custom yang dipilih
final dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// Provider BARU untuk menyimpan bulan yang sedang ditampilkan (defaultnya bulan ini)
final displayedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});