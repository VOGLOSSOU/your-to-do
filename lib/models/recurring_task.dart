class RecurringTask {
  final int id;
  final String title;
  final bool isUrgent;

  const RecurringTask({
    required this.id,
    required this.title,
    this.isUrgent = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'is_urgent': isUrgent ? 1 : 0,
      };

  factory RecurringTask.fromMap(Map<String, dynamic> m) => RecurringTask(
        id: m['id'] as int,
        title: m['title'] as String,
        isUrgent: (m['is_urgent'] as int? ?? 0) == 1,
      );
}
