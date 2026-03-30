import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  static const _key = 'tasks';
  final _uuid = const Uuid();
  List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);
  int get total => _tasks.length;
  int get done => _tasks.where((t) => t.isDone).length;
  double get progress => total == 0 ? 0 : done / total;

  TaskProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final List<dynamic> list = jsonDecode(raw);
    // Only keep tasks from today
    final today = DateTime.now();
    _tasks = list
        .map((e) => Task.fromMap(e))
        .where((t) =>
            t.createdAt.year == today.year &&
            t.createdAt.month == today.month &&
            t.createdAt.day == today.day)
        .toList();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_tasks.map((t) => t.toMap()).toList()),
    );
  }

  Future<void> addTask(String subject, String description) async {
    _tasks.add(Task(
      id: _uuid.v4(),
      subject: subject,
      description: description,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    await _save();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
    notifyListeners();
    await _save();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _save();
  }
}
