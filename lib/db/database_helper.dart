import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/recurring_task.dart';

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

    final newTask = Task(id: _nextId++, title: task.title, description: task.description, date: task.date, isUrgent: task.isUrgent);
    tasks.add(newTask);
    await prefs.setString(key, jsonEncode(tasks.map((t) => t.toMap()).toList()));
    return newTask;
  }

  Future<void> updateTask(int id, String date, {bool? isDone, bool? isUrgent}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date);
    final raw = prefs.getString(key);
    if (raw == null) return;
    final tasks = (jsonDecode(raw) as List)
        .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    tasks[index] = tasks[index].copyWith(isDone: isDone, isUrgent: isUrgent);
    await prefs.setString(key, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  Future<List<Task>> searchTasks(String query, List<String> dates) async {
    final prefs = await SharedPreferences.getInstance();
    final results = <Task>[];
    for (final date in dates) {
      final raw = prefs.getString(_keyForDate(date));
      if (raw == null) continue;
      final tasks = (jsonDecode(raw) as List)
          .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
          .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      results.addAll(tasks);
    }
    return results;
  }

  Future<Map<String, int>> getStatsByDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForDate(date));
    if (raw == null) return {'total': 0, 'done': 0};
    final tasks = (jsonDecode(raw) as List)
        .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return {
      'total': tasks.length,
      'done': tasks.where((t) => t.isDone).length,
    };
  }

  Future<bool> hasTasksForDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForDate(date));
    if (raw == null) return false;
    final List list = jsonDecode(raw);
    return list.isNotEmpty;
  }

  Future<void> saveAllTasks(String date, List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyForDate(date),
      jsonEncode(tasks.map((t) => t.toMap()).toList()),
    );
  }

  // ── Recurring tasks ──────────────────────────────────────────

  static const _recurringKey = 'recurring_tasks';
  static int _nextRecurringId = 1000000;

  Future<List<RecurringTask>> getRecurringTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recurringKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => RecurringTask.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<RecurringTask> addRecurringTask(String title, String description, bool isUrgent) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getRecurringTasks();
    if (tasks.isNotEmpty) {
      final maxId = tasks.map((t) => t.id).reduce((a, b) => a > b ? a : b);
      if (maxId >= _nextRecurringId) _nextRecurringId = maxId + 1;
    }
    final task = RecurringTask(
      id: _nextRecurringId++,
      title: title,
      description: description,
      isUrgent: isUrgent,
    );
    tasks.add(task);
    await prefs.setString(
        _recurringKey, jsonEncode(tasks.map((t) => t.toMap()).toList()));
    return task;
  }

  Future<void> deleteRecurringTask(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = (await getRecurringTasks()).where((t) => t.id != id).toList();
    await prefs.setString(
        _recurringKey, jsonEncode(tasks.map((t) => t.toMap()).toList()));
  }

  String _seededRecurringKey(String date) => 'seeded_recurring_$date';

  Future<void> seedRecurringTasksForDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final recurring = await getRecurringTasks();
    if (recurring.isEmpty) return;

    // Track which recurring IDs have already been seeded for this date
    final seededKey = _seededRecurringKey(date);
    final seededIds = (prefs.getStringList(seededKey) ?? [])
        .map(int.parse)
        .toSet();

    final toAdd = recurring.where((r) => !seededIds.contains(r.id)).toList();
    if (toAdd.isEmpty) return;

    final key = _keyForDate(date);
    final raw = prefs.getString(key);
    final existing = raw != null
        ? (jsonDecode(raw) as List)
            .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <Task>[];

    // Use safe IDs above existing max
    int maxId = _nextId;
    if (existing.isNotEmpty) {
      final existingMax = existing
          .map((t) => t.id ?? 0)
          .reduce((a, b) => a > b ? a : b);
      if (existingMax >= maxId) maxId = existingMax + 1;
    }

    for (final r in toAdd) {
      existing.add(Task(
        id: maxId++,
        title: r.title,
        description: r.description,
        date: date,
        isUrgent: r.isUrgent,
      ));
      seededIds.add(r.id);
    }
    _nextId = maxId;

    await prefs.setString(
        key, jsonEncode(existing.map((t) => t.toMap()).toList()));
    await prefs.setStringList(
        seededKey, seededIds.map((id) => id.toString()).toList());
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
