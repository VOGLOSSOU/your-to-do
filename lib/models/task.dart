class Task {
  final int? id;
  final String title;
  final String date; // YYYY-MM-DD
  final bool isDone;

  const Task({
    this.id,
    required this.title,
    required this.date,
    this.isDone = false,
  });

  Task copyWith({bool? isDone}) => Task(
        id: id,
        title: title,
        date: date,
        isDone: isDone ?? this.isDone,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'date': date,
        'is_done': isDone ? 1 : 0,
      };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
        id: m['id'] as int?,
        title: m['title'] as String,
        date: m['date'] as String,
        isDone: (m['is_done'] as int) == 1,
      );
}
