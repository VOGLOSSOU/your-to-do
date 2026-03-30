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
import '../widgets/search_results.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSheet() {
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
    final isToday = selected == today;
    final canAdd = selected == today || selected == tomorrow;
    final isPast = selected.isBefore(today);
    final isSearching = provider.isSearching;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isSearching
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: GoogleFonts.inter(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Search tasks...',
                              hintStyle: GoogleFonts.inter(
                                  color: Colors.grey.shade400),
                              border: InputBorder.none,
                            ),
                            onChanged: (q) => provider.search(q),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            provider.closeSearch();
                          },
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Tasks',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            // Search icon
                            GestureDetector(
                              onTap: () => provider.openSearch(),
                              child: Icon(Icons.search,
                                  size: 22,
                                  color: isDark
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade500),
                            ),
                            const SizedBox(width: 14),
                            // Dark mode toggle
                            GestureDetector(
                              onTap: () => themeProvider.toggle(),
                              child: Icon(
                                isDark
                                    ? Icons.light_mode_outlined
                                    : Icons.dark_mode_outlined,
                                size: 22,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade500,
                              ),
                            ),
                            if (isToday && provider.total > 0) ...[
                              const SizedBox(width: 14),
                              GestureDetector(
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (_) => ChangeNotifierProvider.value(
                                    value: provider,
                                    child: const SummarySheet(),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.bar_chart,
                                          size: 15,
                                          color: isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Summary',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
            ),

            // Normal view
            if (!isSearching) ...[
              const SizedBox(height: 16),
              const WeekStrip(),
              const SizedBox(height: 20),
              const ProgressHeader(),
              if (provider.total > 0) const _FilterBar(),
            ] else
              const SizedBox(height: 16),

            // Content
            Expanded(
              child: isSearching
                  ? const SearchResults()
                  : tasks.isEmpty
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
                                provider.filter == TaskFilter.all
                                    ? 'No tasks for this day'
                                    : 'No tasks in this category',
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
      floatingActionButton: !isSearching && canAdd
          ? FloatingActionButton(
              onPressed: _showAddSheet,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 2,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final current = provider.filter;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          _Chip(
            label: 'All',
            selected: current == TaskFilter.all,
            onTap: () => provider.setFilter(TaskFilter.all),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Urgent',
            selected: current == TaskFilter.urgent,
            onTap: () => provider.setFilter(TaskFilter.urgent),
            dotColor: Colors.red,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Normal',
            selected: current == TaskFilter.normal,
            onTap: () => provider.setFilter(TaskFilter.normal),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? Colors.white : dotColor,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Theme.of(context).colorScheme.surface : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
