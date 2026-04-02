import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/task.dart';
import '../models/recurring_task.dart';

enum TaskFilter { all, urgent, normal }

class TaskProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final _fmt = DateFormat('yyyy-MM-dd');

  DateTime _selectedDate = DateTime.now();
  List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  Set<String> _activeDates = {};
  String _searchQuery = '';
  List<Task> _searchResults = [];
  bool _isSearching = false;
  List<RecurringTask> _recurringTasks = [];

  DateTime get selectedDate => _selectedDate;
  TaskFilter get filter => _filter;
  Set<String> get activeDates => _activeDates;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  List<Task> get searchResults => List.unmodifiable(_searchResults);
  List<RecurringTask> get recurringTasks => List.unmodifiable(_recurringTasks);
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
    await _db.seedRecurringTasksForDate(selectedDateKey);
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

  void openSearch() {
    _isSearching = true;
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  void closeSearch() {
    _isSearching = false;
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    final today = DateTime.now();
    final dates = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 5 - i));
      return _fmt.format(d);
    });
    _searchResults = await _db.searchTasks(query, dates);
    notifyListeners();
  }

  List<Task> get undoneTasks =>
      List.unmodifiable(_tasks.where((t) => !t.isDone).toList());

  Future<void> carryOverToTomorrow() async {
    final undone = _tasks.where((t) => !t.isDone).toList();
    if (undone.isEmpty) return;
    final tomorrow = _fmt.format(DateTime.now().add(const Duration(days: 1)));
    // Copy to tomorrow
    for (final task in undone) {
      await _db.insertTask(Task(
        title: task.title,
        date: tomorrow,
        isUrgent: task.isUrgent,
      ));
    }
    // Remove from today
    for (final task in undone) {
      await _db.deleteTask(task.id!, selectedDateKey);
    }
    _tasks.removeWhere((t) => !t.isDone);
    _activeDates.add(tomorrow);
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
