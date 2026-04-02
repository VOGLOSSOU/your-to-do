class Task {
  final int? id;
  final String title;
  final String description;
  final String date; // YYYY-MM-DD
  final bool isDone;
  final bool isUrgent;

  const Task({
    this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.isDone = false,
    this.isUrgent = false,
  });

  Task copyWith({bool? isDone, bool? isUrgent}) => Task(
        id: id,
        title: title,
        description: description,
        date: date,
        isDone: isDone ?? this.isDone,
        isUrgent: isUrgent ?? this.isUrgent,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'description': description,
        'date': date,
        'is_done': isDone ? 1 : 0,
        'is_urgent': isUrgent ? 1 : 0,
      };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
        id: m['id'] as int?,
        title: m['title'] as String,
        description: m['description'] as String? ?? '',
        date: m['date'] as String,
        isDone: (m['is_done'] as int) == 1,
        isUrgent: (m['is_urgent'] as int? ?? 0) == 1,
      );
}
