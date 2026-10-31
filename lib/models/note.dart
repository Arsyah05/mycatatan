import 'package:flutter/material.dart';

/// Kategori yang tersedia untuk sebuah catatan.
enum NoteCategory {
  pribadi('Pribadi', Icons.person_outline_rounded),
  kerja('Kerja', Icons.work_outline_rounded),
  kuliah('Kuliah', Icons.school_outlined),
  penting('Penting', Icons.star_outline_rounded);

  const NoteCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Pilihan warna kartu catatan.
enum NoteColor {
  biru('Biru', Color(0xFF2563EB), Color(0xFFDBEAFE)),
  hijau('Hijau', Color(0xFF059669), Color(0xFFD1FAE5)),
  kuning('Kuning', Color(0xFFD97706), Color(0xFFFEF3C7)),
  pink('Pink', Color(0xFFDB2777), Color(0xFFFCE7F3)),
  ungu('Ungu', Color(0xFF7C3AED), Color(0xFFEDE9FE));

  const NoteColor(this.label, this.color, this.softColor);

  final String label;
  final Color color;
  final Color softColor;
}

/// Tingkat prioritas sebuah catatan.
enum NotePriority {
  rendah('Rendah', Color(0xFF059669), Color(0xFFD1FAE5)),
  sedang('Sedang', Color(0xFFD97706), Color(0xFFFEF3C7)),
  tinggi('Tinggi', Color(0xFFDC2626), Color(0xFFFEE2E2));

  const NotePriority(this.label, this.color, this.softColor);

  final String label;
  final Color color;
  final Color softColor;
}

/// Model data utama aplikasi MyCatatan.
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.color,
    required this.priority,
    required this.createdAt,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final String content;
  final NoteCategory category;
  final NoteColor color;
  final NotePriority priority;
  final DateTime createdAt;
  final bool isArchived;

  /// Ringkasan singkat untuk ditampilkan pada kartu catatan.
  String get summary => content.trim().replaceAll(RegExp(r'\s+'), ' ');

  Note copyWith({
    String? title,
    String? content,
    NoteCategory? category,
    NoteColor? color,
    NotePriority? priority,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

/// Hasil yang dikirim kembali dari halaman detail ke halaman beranda.
class NoteResult {
  const NoteResult.saved(this.note) : deleted = false;

  const NoteResult.deleted() : note = null, deleted = true;

  final Note? note;
  final bool deleted;
}

const List<String> _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const List<String> _dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

/// Format tanggal ringkas, misalnya "Hari ini" atau "27 Oktober 2026".
String formatNoteDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final difference = today.difference(target).inDays;

  if (difference == 0) return 'Hari ini';
  if (difference == 1) return 'Kemarin';

  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}

/// Format tanggal lengkap dengan nama hari dan jam.
String formatNoteDateTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final dayName = _dayNames[date.weekday - 1];

  return '$dayName, ${date.day} ${_monthNames[date.month - 1]} '
      '${date.year} • $hour.$minute';
}
