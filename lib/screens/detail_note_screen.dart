import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_theme.dart';
import 'add_note_screen.dart';

/// Halaman detail yang menampilkan isi lengkap sebuah catatan.
class DetailNoteScreen extends StatefulWidget {
  const DetailNoteScreen({super.key, required this.note});

  final Note note;

  @override
  State<DetailNoteScreen> createState() => _DetailNoteScreenState();
}

class _DetailNoteScreenState extends State<DetailNoteScreen> {
  late Note _note;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  void _close() {
    Navigator.of(context).pop(_hasChanges ? NoteResult.saved(_note) : null);
  }

  Future<void> _editNote() async {
    final Note? updatedNote = await Navigator.of(context).push<Note>(
      MaterialPageRoute<Note>(builder: (_) => AddNoteScreen(note: _note)),
    );

    if (updatedNote == null || !mounted) return;

    setState(() {
      _note = updatedNote;
      _hasChanges = true;
    });

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Perubahan catatan berhasil disimpan.')),
      );
  }

  Future<void> _deleteNote() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
              size: 28,
            ),
          ),
          title: const Text('Hapus catatan?'),
          content: Text(
            'Catatan "${_note.title}" akan dihapus permanen. '
            'Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    Navigator.of(context).pop(const NoteResult.deleted());
  }

  void _toggleArchive() {
    setState(() {
      _note = _note.copyWith(isArchived: !_note.isArchived);
      _hasChanges = true;
    });

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _note.isArchived
                ? 'Catatan dipindahkan ke arsip.'
                : 'Catatan dikeluarkan dari arsip.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return PopScope<NoteResult>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _close();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Kembali',
            onPressed: _close,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Detail Catatan'),
          actions: [
            IconButton(
              tooltip: _note.isArchived
                  ? 'Keluarkan dari arsip'
                  : 'Arsipkan catatan',
              onPressed: _toggleArchive,
              icon: Icon(
                _note.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
            ),
            const SizedBox(width: 4),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNoteHeader(textTheme),
                  const SizedBox(height: 18),
                  _buildDateCard(textTheme),
                  const SizedBox(height: 24),
                  Text('Isi Catatan', style: textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _note.content.isEmpty
                          ? 'Belum ada isi catatan.'
                          : _note.content,
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                        color: _note.content.isEmpty
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Kamu bisa mengedit atau menghapus catatan ini '
                          'kapan saja.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildActionBar(),
      ),
    );
  }

  Widget _buildNoteHeader(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _note.color.softColor,
            _note.color.softColor.withValues(alpha: 0.35),
            AppColors.background,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _note.color.color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _note.color.color.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _note.category.icon,
                  color: _note.color.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _note.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 23,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: _note.category.icon,
                label: _note.category.label,
                color: _note.color.color,
                backgroundColor: AppColors.background.withValues(alpha: 0.8),
              ),
              _InfoChip(
                icon: Icons.flag_outlined,
                label: 'Prioritas ${_note.priority.label}',
                color: _note.priority.color,
                backgroundColor: _note.priority.softColor,
              ),
              if (_note.isArchived)
                const _InfoChip(
                  icon: Icons.inventory_2_outlined,
                  label: 'Diarsipkan',
                  color: Color(0xFF7C3AED),
                  backgroundColor: Color(0xFFEDE9FE),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 19,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dibuat pada',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatNoteDateTime(_note.createdAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _editNote,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 19),
                      label: const Text('Edit'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _deleteNote,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        side: BorderSide(
                          color: AppColors.danger.withValues(alpha: 0.35),
                        ),
                        backgroundColor: const Color(0xFFFEF2F2),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 19),
                      label: const Text('Hapus'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
