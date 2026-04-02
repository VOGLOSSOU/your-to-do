class RecurringTask {
  final int id;
  final String title;
  final String description;
  final bool isUrgent;

  const RecurringTask({
    required this.id,
    required this.title,
    this.description = '',
    this.isUrgent = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'is_urgent': isUrgent ? 1 : 0,
      };

  factory RecurringTask.fromMap(Map<String, dynamic> m) => RecurringTask(
        id: m['id'] as int,
        title: m['title'] as String,
        description: m['description'] as String? ?? '',
        isUrgent: (m['is_urgent'] as int? ?? 0) == 1,
      );
}
