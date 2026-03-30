import 'dart:convert';

class Task {
  final String id;
  final String subject;
  final String description;
  bool isDone;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.subject,
    required this.description,
    this.isDone = false,
    required this.createdAt,
  });

  Task copyWith({bool? isDone}) {
    return Task(
      id: id,
      subject: subject,
      description: description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'subject': subject,
        'description': description,
        'isDone': isDone,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        subject: map['subject'],
        description: map['description'],
        isDone: map['isDone'],
        createdAt: DateTime.parse(map['createdAt']),
      );

  String toJson() => jsonEncode(toMap());
  factory Task.fromJson(String source) => Task.fromMap(jsonDecode(source));
}
