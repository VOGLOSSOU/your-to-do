import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';

class TaskDetailSheet extends StatelessWidget {
  final Task task;
  const TaskDetailSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: task.isDone
                      ? cs.onSurface
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.isDone ? 'Done' : 'To do',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: task.isDone
                        ? cs.surface
                        : isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                  ),
                ),
              ),
              if (task.isUrgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag, size: 12, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        'Urgent',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            task.title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              decorationColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(color: cs.outline, height: 1),
          const SizedBox(height: 16),

          // Description label
          Text(
            'Description',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Description content
          Text(
            task.description.isEmpty ? '—' : task.description,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: task.description.isEmpty
                  ? (isDark ? Colors.grey.shade600 : Colors.grey.shade400)
                  : cs.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: cs.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
