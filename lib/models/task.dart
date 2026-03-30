class Task {
  final int? id;
  final String title;
  final String date; // YYYY-MM-DD
  final String? startTime; // HH:mm
  final String? endTime; // HH:mm
  final bool isDone;

  const Task({
    this.id,
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    this.isDone = false,
  });

  Task copyWith({bool? isDone}) => Task(
        id: id,
        title: title,
        date: date,
        startTime: startTime,
        endTime: endTime,
        isDone: isDone ?? this.isDone,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        'is_done': isDone ? 1 : 0,
      };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
        id: m['id'] as int?,
        title: m['title'] as String,
        date: m['date'] as String,
        startTime: m['start_time'] as String?,
        endTime: m['end_time'] as String?,
        isDone: (m['is_done'] as int) == 1,
      );
}
