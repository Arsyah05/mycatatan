import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_theme.dart';

/// Deretan filter kategori yang bisa digulir secara horizontal.
class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    super.key,
    required this.selected,
    required this.onSelected,
    this.compact = false,
  });

  /// `null` berarti filter "Semua".
  final NoteCategory? selected;
  final ValueChanged<NoteCategory?> onSelected;
  final bool compact;

  static const List<NoteCategory?> _filters = [
    null,
    NoteCategory.penting,
    NoteCategory.pribadi,
    NoteCategory.kerja,
    NoteCategory.kuliah,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 36 : 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final NoteCategory? category = _filters[index];
          final bool isSelected = selected == category;
          final String label = category?.label ?? 'Semua';
          final IconData icon = category?.icon ?? Icons.grid_view_rounded;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(category),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: compact ? 15 : 16,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: compact ? 5 : 6),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: compact ? 11.5 : null,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
