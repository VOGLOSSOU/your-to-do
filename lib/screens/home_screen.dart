import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/week_strip.dart';
import '../widgets/progress_header.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_sheet.dart';

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
    final today = DateTime.now();
    final isToday = provider.selectedDate.year == today.year &&
        provider.selectedDate.month == today.month &&
        provider.selectedDate.day == today.day;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // App title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'My Tasks',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Week strip
            const WeekStrip(),
            const SizedBox(height: 20),
            // Progress
            const ProgressHeader(),
            // Task list
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks for this day',
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade400,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: tasks.length,
                      itemBuilder: (_, i) => TaskTile(task: tasks[i], readOnly: !isToday),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: isToday
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
