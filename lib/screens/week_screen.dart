import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../db/database_helper.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  final _db = DatabaseHelper.instance;
  final _fmt = DateFormat('yyyy-MM-dd');
  List<_DayStat> _stats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().addListener(_onTasksChanged);
    });
  }

  void _onTasksChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 5 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final stats = await Future.wait(days.map((day) async {
      final key = _fmt.format(day);
      final s = await _db.getStatsByDate(key);
      return _DayStat(date: day, total: s['total']!, done: s['done']!);
    }));

    if (mounted) setState(() { _stats = stats; _loading = false; });
  }

  @override
  void dispose() {
    context.read<TaskProvider>().removeListener(_onTasksChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final today = DateTime.now();

    // Consistency score: days with tasks that are all done
    final activeDays = _stats.where((s) => s.total > 0).length;
    final validatedDays = _stats.where((s) => s.total > 0 && s.done == s.total).length;

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
                    'My Week',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => themeProvider.toggle(),
                    child: Icon(
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      size: 22,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Consistency score
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                activeDays == 0
                    ? 'No tasks recorded this week'
                    : '$validatedDays / $activeDays active days fully completed',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Days list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _stats.length,
                        itemBuilder: (_, i) {
                          final stat = _stats[i];
                          final isToday = stat.date.year == today.year &&
                              stat.date.month == today.month &&
                              stat.date.day == today.day;
                          final isTomorrow = stat.date.difference(
                                  DateTime(today.year, today.month, today.day))
                              .inDays == 1;
                          final isPast = stat.date.isBefore(
                              DateTime(today.year, today.month, today.day));

                          return _DayCard(
                            stat: stat,
                            isToday: isToday,
                            isTomorrow: isTomorrow,
                            isPast: isPast,
                            cs: cs,
                            isDark: isDark,
                            onTap: () {
                              context.read<TaskProvider>().selectDate(stat.date);
                              // Switch to tasks tab
                              DefaultTabController.of(context);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final _DayStat stat;
  final bool isToday;
  final bool isTomorrow;
  final bool isPast;
  final ColorScheme cs;
  final bool isDark;
  final VoidCallback onTap;

  const _DayCard({
    required this.stat,
    required this.isToday,
    required this.isTomorrow,
    required this.isPast,
    required this.cs,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final allDone = stat.total > 0 && stat.done == stat.total;
    final partial = stat.total > 0 && stat.done < stat.total;
    final noTasks = stat.total == 0;

    Color borderColor;
    if (allDone) {
      borderColor = Colors.green.shade400;
    } else if (isToday) {
      borderColor = cs.onSurface;
    } else {
      borderColor = cs.outline;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: allDone
              ? (isDark ? const Color(0xFF1A2A1A) : const Color(0xFFF0FFF0))
              : cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isToday ? 1.5 : 1),
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: allDone
                    ? Colors.green.shade400
                    : noTasks
                        ? cs.surfaceContainerHighest
                        : isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey.shade100,
              ),
              child: allDone
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : partial
                      ? Icon(Icons.timelapse,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade400,
                          size: 20)
                      : Icon(Icons.remove,
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                          size: 20),
            ),
            const SizedBox(width: 14),

            // Day info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isToday
                            ? 'Today'
                            : isTomorrow
                                ? 'Tomorrow'
                                : DateFormat('EEEE').format(stat.date),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.onSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Today',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: cs.surface,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d').format(stat.date),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  noTasks
                      ? 'No tasks'
                      : '${stat.done}/${stat.total}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: allDone
                        ? Colors.green.shade500
                        : cs.onSurface,
                  ),
                ),
                if (!noTasks) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stat.total == 0 ? 0 : stat.done / stat.total,
                        minHeight: 4,
                        backgroundColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          allDone ? Colors.green.shade400 : cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayStat {
  final DateTime date;
  final int total;
  final int done;
  const _DayStat({required this.date, required this.total, required this.done});
}
