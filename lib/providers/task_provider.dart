import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/task.dart';

enum TaskFilter { all, urgent, normal }

class TaskProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final _fmt = DateFormat('yyyy-MM-dd');

  DateTime _selectedDate = DateTime.now();
  List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  Set<String> _activeDates = {};

  DateTime get selectedDate => _selectedDate;
  TaskFilter get filter => _filter;
  Set<String> get activeDates => _activeDates;
  int get total => _tasks.length;
  int get done => _tasks.where((t) => t.isDone).length;
  double get progress => total == 0 ? 0.0 : done / total;
  String get selectedDateKey => _fmt.format(_selectedDate);

  List<Task> get tasks {
    switch (_filter) {
      case TaskFilter.urgent:
        return List.unmodifiable(_tasks.where((t) => t.isUrgent).toList());
      case TaskFilter.normal:
        return List.unmodifiable(_tasks.where((t) => !t.isUrgent).toList());
      case TaskFilter.all:
        return List.unmodifiable(_tasks);
    }
  }

  void setFilter(TaskFilter f) {
    _filter = f;
    notifyListeners();
  }

  TaskProvider() {
    _loadActiveDates();
    loadTasks();
  }

  Future<void> _loadActiveDates() async {
    final today = DateTime.now();
    final dates = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return _fmt.format(d);
    });
    final results = await Future.wait(dates.map(_db.hasTasksForDate));
    _activeDates = {
      for (int i = 0; i < dates.length; i++)
        if (results[i]) dates[i]
    };
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await loadTasks();
  }

  Future<void> loadTasks() async {
    final tasks = await _db.getTasksByDate(selectedDateKey);
    _tasks = _sorted(tasks);
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    final task = await _db.insertTask(Task(title: title, date: selectedDateKey));
    _tasks = _sorted([..._tasks, task]);
    _activeDates.add(selectedDateKey);
    notifyListeners();
  }

  Future<void> toggleTask(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final newVal = !_tasks[index].isDone;
    await _db.updateTask(id, selectedDateKey, isDone: newVal);
    _tasks[index] = _tasks[index].copyWith(isDone: newVal);
    notifyListeners();
  }

  Future<void> toggleUrgent(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final newVal = !_tasks[index].isUrgent;
    await _db.updateTask(id, selectedDateKey, isUrgent: newVal);
    _tasks[index] = _tasks[index].copyWith(isUrgent: newVal);
    _tasks = _sorted(_tasks);
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id, selectedDateKey);
    _tasks.removeWhere((t) => t.id == id);
    if (_tasks.isEmpty) _activeDates.remove(selectedDateKey);
    notifyListeners();
  }

  // Urgent tasks always on top, done tasks always at the bottom
  List<Task> _sorted(List<Task> tasks) {
    final urgent = tasks.where((t) => t.isUrgent && !t.isDone).toList();
    final normal = tasks.where((t) => !t.isUrgent && !t.isDone).toList();
    final donetasks = tasks.where((t) => t.isDone).toList();
    return [...urgent, ...normal, ...donetasks];
  }
}
