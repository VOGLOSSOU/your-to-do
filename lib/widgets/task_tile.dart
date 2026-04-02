import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'task_detail_sheet.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool readOnly;
  const TaskTile({super.key, required this.task, this.readOnly = false});

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskDetailSheet(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: readOnly ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: cs.onSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: cs.surface, size: 20),
      ),
      onDismissed: (_) => provider.deleteTask(task.id!),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: task.isDone ? cs.surfaceContainerHighest : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task.isUrgent && !task.isDone
                ? Colors.red.shade200
                : cs.outline,
          ),
        ),
        child: Row(
          children: [
            // Checkbox — tap to toggle done
            GestureDetector(
              onTap: readOnly ? null : () => provider.toggleTask(task.id!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? cs.onSurface : Colors.transparent,
                  border: Border.all(
                    color: task.isDone
                        ? cs.onSurface
                        : isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: task.isDone
                    ? Icon(Icons.check, size: 13, color: cs.surface)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            if (task.isUrgent && !task.isDone)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            // Title + description — tap to open detail
            Expanded(
              child: GestureDetector(
                onTap: () => _openDetail(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: task.isDone
                            ? (isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400)
                            : cs.onSurface,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        decorationColor: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!readOnly) ...[
              GestureDetector(
                onTap: () => provider.toggleUrgent(task.id!),
                child: Icon(
                  task.isUrgent ? Icons.flag : Icons.flag_outlined,
                  size: 18,
                  color: task.isUrgent
                      ? Colors.red
                      : isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => provider.deleteTask(task.id!),
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
