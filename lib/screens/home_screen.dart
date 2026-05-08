import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/week_strip.dart';
import '../widgets/progress_header.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/summary_sheet.dart';
import '../widgets/recurring_tasks_sheet.dart';
import '../widgets/notification_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TaskProvider>(),
        child: const AddTaskSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selected = DateTime(
      provider.selectedDate.year,
      provider.selectedDate.month,
      provider.selectedDate.day,
    );
    final canAdd = selected == today || selected == tomorrow;
    final isPast = selected.isBefore(today);
    final isToday = selected == today;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'tasks',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: cs.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => const NotificationSheet(),
                        ),
                        child: Icon(Icons.notifications_outlined, size: 22, color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: cs.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => ChangeNotifierProvider.value(
                            value: provider,
                            child: const RecurringTasksSheet(),
                          ),
                        ),
                        child: Icon(Icons.repeat, size: 22, color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () => themeProvider.toggle(Theme.of(context).brightness),
                        child: Icon(
                          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          size: 22,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (isToday && provider.total > 0) ...[
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: cs.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => ChangeNotifierProvider.value(
                              value: provider,
                              child: const SummarySheet(),
                            ),
                          ),
                          child: Icon(Icons.bar_chart, size: 22, color: Colors.grey.shade500),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const WeekStrip(),
            const SizedBox(height: 20),
            const ProgressHeader(),

            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 48,
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks for this day',
                            style: GoogleFonts.inter(
                              color: isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: tasks.length,
                      itemBuilder: (_, i) => TaskTile(
                        task: tasks[i],
                        readOnly: isPast,
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: canAdd
          ? FloatingActionButton(
              onPressed: () => _showAddSheet(context),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 2,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
