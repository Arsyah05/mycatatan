import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_theme.dart';

/// Kartu ringkasan catatan yang tampil di halaman beranda dan arsip.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.compact = false,
  });

  final Note note;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double iconSize = compact ? 40 : 48;
    final double gap = compact ? 10 : 14;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: note.color.softColor,
                    borderRadius: BorderRadius.circular(compact ? 12 : 14),
                  ),
                  child: Icon(
                    note.category.icon,
                    color: note.color.color,
                    size: compact ? 22 : null,
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: compact
                                  ? textTheme.titleSmall
                                  : textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PriorityTag(
                            priority: note.priority,
                            compact: compact,
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 3 : 5),
                      Text(
                        note.summary,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: compact ? 11.5 : null,
                        ),
                      ),
                      SizedBox(height: compact ? 6 : 10),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: compact ? 12 : 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              formatNoteDate(note.createdAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: compact ? 10.5 : null,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CategoryTag(note: note, compact: compact),
                        ],
                      ),
                    ],
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

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.note, required this.compact});

  final Note note;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: note.color.softColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        note.category.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: note.color.color,
          fontSize: compact ? 9.5 : 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PriorityTag extends StatelessWidget {
  const _PriorityTag({required this.priority, required this.compact});

  final NotePriority priority;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: priority.softColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: priority.color,
              fontSize: compact ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
