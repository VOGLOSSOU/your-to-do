import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = provider.selectedDate;
    final today = DateTime.now();

    // J-5 → today (index 5) → tomorrow (index 6)
    final days = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 5 - i));
      return DateTime(d.year, d.month, d.day);
    });

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 7,
        itemBuilder: (_, i) {
          final day = days[i];
          final isSelected = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          final isToday = i == 5;
          final isTomorrow = i == 6;
          final dateKey = DateFormat('yyyy-MM-dd').format(day);
          final hasTask = provider.activeDates.contains(dateKey);

          return GestureDetector(
            onTap: () => provider.selectDate(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? cs.onSurface : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day)[0].toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? cs.surface.withValues(alpha:0.7)
                          : isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isTomorrow && !isSelected ? '+1' : '${day.day}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected || isToday || isTomorrow
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? cs.surface
                          : isToday
                              ? cs.onSurface
                              : isTomorrow
                                  ? isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600
                                  : isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade500,
                    ),
                  ),
                  if (hasTask) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? cs.surface.withValues(alpha:0.6)
                            : cs.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
