import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class RecurringTasksSheet extends StatefulWidget {
  const RecurringTasksSheet({super.key});

  @override
  State<RecurringTasksSheet> createState() => _RecurringTasksSheetState();
}

class _RecurringTasksSheetState extends State<RecurringTasksSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isUrgent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    if (!_formKey.currentState!.validate()) return;
    context.read<TaskProvider>().addRecurringTask(
          _controller.text.trim(),
          isUrgent: _isUrgent,
        );
    _controller.clear();
    setState(() => _isUrgent = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recurring = provider.recurringTasks;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      color: cs.surface,
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            children: [
              Icon(Icons.repeat, size: 18, color: cs.onSurface),
              const SizedBox(width: 8),
              Text(
                'Daily recurring tasks',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'These tasks appear automatically every day.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),

          // Add field
          Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'e.g. Check emails, Daily standup...',
                      hintStyle: GoogleFonts.inter(
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                          fontSize: 13),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                // Urgent toggle
                GestureDetector(
                  onTap: () => setState(() => _isUrgent = !_isUrgent),
                  child: Icon(
                    _isUrgent ? Icons.flag : Icons.flag_outlined,
                    size: 22,
                    color: _isUrgent ? Colors.red : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                // Add button
                GestureDetector(
                  onTap: _add,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.onSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.add, color: cs.surface, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // List
          if (recurring.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No recurring tasks yet.',
                  style: GoogleFonts.inter(
                    color:
                        isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: recurring.length,
                itemBuilder: (_, i) {
                  final task = recurring[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.repeat,
                            size: 14,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400),
                        const SizedBox(width: 10),
                        if (task.isUrgent)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            task.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              provider.deleteRecurringTask(task.id),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
