import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool readOnly;
  const TaskTile({super.key, required this.task, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: readOnly ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
      ),
      onDismissed: (_) => provider.deleteTask(task.id!),
      child: GestureDetector(
        onTap: readOnly ? null : () => provider.toggleTask(task.id!),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: task.isDone ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: task.isUrgent && !task.isDone
                  ? Colors.red.shade200
                  : task.isDone
                      ? Colors.grey.shade200
                      : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? Colors.black : Colors.transparent,
                  border: Border.all(
                    color: task.isDone ? Colors.black : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              // Urgent dot
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
              // Title
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: task.isDone ? Colors.grey.shade400 : Colors.black,
                    decoration:
                        task.isDone ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey.shade400,
                  ),
                ),
              ),
              if (!readOnly) ...[
                // Flag button
                GestureDetector(
                  onTap: () => provider.toggleUrgent(task.id!),
                  child: Icon(
                    task.isUrgent ? Icons.flag : Icons.flag_outlined,
                    size: 18,
                    color: task.isUrgent ? Colors.red : Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 10),
                // Delete button
                GestureDetector(
                  onTap: () => provider.deleteTask(task.id!),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
