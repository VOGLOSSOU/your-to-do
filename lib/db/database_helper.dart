import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  static int _nextId = 0;

  String _keyForDate(String date) => 'tasks_$date';

  Future<void> _ensureIdCounter(List<Task> allTasks) async {
    if (allTasks.isNotEmpty) {
      final maxId = allTasks.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b);
      if (maxId >= _nextId) _nextId = maxId + 1;
    }
  }

  Future<List<Task>> getTasksByDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForDate(date));
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    final tasks = list.map((e) => Task.fromMap(Map<String, dynamic>.from(e))).toList();
    await _ensureIdCounter(tasks);
    return tasks;
  }

  Future<Task> insertTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(task.date);
    final raw = prefs.getString(key);
    final List<dynamic> list = raw != null ? jsonDecode(raw) : [];
    final tasks = list.map((e) => Task.fromMap(Map<String, dynamic>.from(e))).toList();

    final newTask = Task(id: _nextId++, title: task.title, date: task.date);
    tasks.add(newTask);
    await prefs.setString(key, jsonEncode(tasks.map((t) => t.toMap()).toList()));
    return newTask;
  }

  Future<void> updateDone(int id, bool isDone, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date);
    final raw = prefs.getString(key);
    if (raw == null) return;
    final tasks = (jsonDecode(raw) as List)
        .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    tasks[index] = tasks[index].copyWith(isDone: isDone);
    await prefs.setString(key, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  Future<void> deleteTask(int id, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date);
    final raw = prefs.getString(key);
    if (raw == null) return;
    final tasks = (jsonDecode(raw) as List)
        .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
        .where((t) => t.id != id)
        .toList();
    await prefs.setString(key, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }
}
