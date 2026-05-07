import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/task.dart';
import '../models/recurring_task.dart';

class TaskProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final _fmt = DateFormat('yyyy-MM-dd');

  DateTime _selectedDate = DateTime.now();
  List<Task> _tasks = [];
  Set<String> _activeDates = {};
  List<RecurringTask> _recurringTasks = [];

  DateTime get selectedDate => _selectedDate;
  Set<String> get activeDates => _activeDates;
  List<RecurringTask> get recurringTasks => List.unmodifiable(_recurringTasks);
  int get total => _tasks.length;
  int get done => _tasks.where((t) => t.isDone).length;
  double get progress => total == 0 ? 0.0 : done / total;
  String get selectedDateKey => _fmt.format(_selectedDate);
  List<Task> get tasks => List.unmodifiable(_tasks);

  TaskProvider() {
    _loadActiveDates();
    _loadRecurringTasks();
    loadTasks();
  }

  Future<void> _loadRecurringTasks() async {
    _recurringTasks = await _db.getRecurringTasks();
    notifyListeners();
  }

  Future<void> addRecurringTask(String title, String description, {bool isUrgent = false}) async {
    final task = await _db.addRecurringTask(title, description, isUrgent);
    _recurringTasks.add(task);
    await loadTasks();
  }

  Future<void> deleteRecurringTask(int id) async {
    await _db.deleteRecurringTask(id);
    _recurringTasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> _loadActiveDates() async {
    final today = DateTime.now();
    final dates = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 5 - i));
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
    final today = DateTime.now();
    final todayKey = _fmt.format(DateTime(today.year, today.month, today.day));
    if (selectedDateKey.compareTo(todayKey) >= 0) {
      await _db.seedRecurringTasksForDate(selectedDateKey);
    }
    final tasks = await _db.getTasksByDate(selectedDateKey);
    _tasks = _sorted(tasks);
    notifyListeners();
  }

  Future<void> addTask(String title, String description) async {
    final task = await _db.insertTask(Task(title: title, description: description, date: selectedDateKey));
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

  List<Task> get undoneTasks =>
      List.unmodifiable(_tasks.where((t) => !t.isDone).toList());

  Future<void> carryOverToTomorrow() async {
    final undone = _tasks.where((t) => !t.isDone).toList();
    if (undone.isEmpty) return;
    final tomorrow = _fmt.format(DateTime.now().add(const Duration(days: 1)));
    for (final task in undone) {
      await _db.insertTask(Task(
        title: task.title,
        date: tomorrow,
        isUrgent: task.isUrgent,
      ));
    }
    for (final task in undone) {
      await _db.deleteTask(task.id!, selectedDateKey);
    }
    _tasks.removeWhere((t) => !t.isDone);
    _activeDates.add(tomorrow);
    if (_tasks.isEmpty) _activeDates.remove(selectedDateKey);
    notifyListeners();
  }

  List<Task> _sorted(List<Task> tasks) {
    final urgent = tasks.where((t) => t.isUrgent && !t.isDone).toList();
    final normal = tasks.where((t) => !t.isUrgent && !t.isDone).toList();
    final donetasks = tasks.where((t) => t.isDone).toList();
    return [...urgent, ...normal, ...donetasks];
  }
}
