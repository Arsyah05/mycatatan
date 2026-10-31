import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'detail_note_screen.dart';

/// Form untuk menambah catatan baru atau mengedit catatan yang sudah ada.
class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key, this.note});

  /// Jika diisi, halaman ini berjalan dalam mode edit.
  final Note? note;

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  late NoteCategory _category;
  late NoteColor _color;
  late NotePriority _priority;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    final Note? note = widget.note;

    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _category = note?.category ?? NoteCategory.pribadi;
    _color = note?.color ?? NoteColor.biru;
    _priority = note?.priority ?? NotePriority.sedang;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    final Note? oldNote = widget.note;

    final Note savedNote;
    if (oldNote == null) {
      final DateTime now = DateTime.now();
      savedNote = Note(
        id: now.microsecondsSinceEpoch.toString(),
        title: title,
        content: content,
        category: _category,
        color: _color,
        priority: _priority,
        createdAt: now,
      );
    } else {
      savedNote = oldNote.copyWith(
        title: title,
        content: content,
        category: _category,
        color: _color,
        priority: _priority,
      );
    }

    if (_isEditing) {
      Navigator.of(context).pop(savedNote);
      return;
    }

    // Setelah catatan baru disimpan, langsung buka halaman detail.
    final NoteResult? result = await Navigator.of(context).push<NoteResult>(
      MaterialPageRoute<NoteResult>(
        builder: (_) => DetailNoteScreen(note: savedNote),
      ),
    );

    if (!mounted) return;

    if (result == null) {
      Navigator.of(context).pop(savedNote);
    } else if (result.deleted) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop(result.note ?? savedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(_isEditing ? 'Edit Catatan' : 'Tambah Catatan'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    label: 'Judul Catatan',
                    controller: _titleController,
                    hint: 'Contoh: Ide proyek baru',
                    prefixIcon: Icons.edit_note_rounded,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul catatan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Isi Catatan',
                    controller: _contentController,
                    hint:
                        'Tulis ide, rencana, atau catatan pentingmu di sini...',
                    minLines: 7,
                    maxLines: 10,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 22),
                  _buildSectionLabel('Kategori'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<NoteCategory>(
                    initialValue: _category,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.category_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    items: NoteCategory.values.map((category) {
                      return DropdownMenuItem<NoteCategory>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              category.icon,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(category.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                  const SizedBox(height: 22),
                  _buildSectionLabel('Warna Catatan'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: NoteColor.values.map((option) {
                      final bool isSelected = _color == option;

                      return InkWell(
                        onTap: () => setState(() => _color = option),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? option.softColor
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? option.color
                                  : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 17,
                                height: 17,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: option.color,
                                  shape: BoxShape.circle,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 11,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                option.label,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: isSelected
                                          ? option.color
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  _buildSectionLabel('Prioritas'),
                  const SizedBox(height: 10),
                  Row(
                    children: NotePriority.values.map((option) {
                      final bool isSelected = _priority == option;
                      final bool isLast = option == NotePriority.values.last;

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: isLast ? 0 : 8),
                          child: InkWell(
                            onTap: () => setState(() => _priority = option),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? option.softColor
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? option.color
                                      : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _priorityIcon(option),
                                    size: 19,
                                    color: isSelected
                                        ? option.color
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    option.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: isSelected
                                              ? option.color
                                              : AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _saveNote,
                      icon: const Icon(Icons.save_outlined, size: 20),
                      label: Text(
                        _isEditing ? 'Simpan Perubahan' : 'Simpan Catatan',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: AppColors.textPrimary),
    );
  }

  IconData _priorityIcon(NotePriority priority) {
    switch (priority) {
      case NotePriority.rendah:
        return Icons.keyboard_arrow_down_rounded;
      case NotePriority.sedang:
        return Icons.drag_handle_rounded;
      case NotePriority.tinggi:
        return Icons.keyboard_arrow_up_rounded;
    }
  }
}
