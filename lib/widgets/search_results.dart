import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({super.key});

  String _dateLabel(String dateKey) {
    final fmt = DateFormat('yyyy-MM-dd');
    final date = fmt.parse(dateKey);
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    final tomorrowKey = DateFormat('yyyy-MM-dd')
        .format(today.add(const Duration(days: 1)));

    if (dateKey == todayKey) return 'Today';
    if (dateKey == tomorrowKey) return 'Tomorrow';
    return DateFormat('EEE, MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final query = provider.searchQuery;
    final results = provider.searchResults;

    if (query.trim().isEmpty) {
      return Center(
        child: Text(
          'Type to search across all days',
          style: GoogleFonts.inter(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No results for "$query"',
              style: GoogleFonts.inter(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 40),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final task = results[i];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: task.isDone ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Done indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? Colors.black : Colors.transparent,
                  border: Border.all(
                    color: task.isDone ? Colors.black : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(text: task.title, query: query),
                    const SizedBox(height: 3),
                    Text(
                      _dateLabel(task.date),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    final index = lower.indexOf(lowerQ);

    if (index == -1) {
      return Text(
        text,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      );
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: const TextStyle(
              backgroundColor: Color(0xFFFFE580),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}
