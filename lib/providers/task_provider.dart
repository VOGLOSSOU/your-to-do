import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final _fmt = DateFormat('yyyy-MM-dd');

  DateTime _selectedDate = DateTime.now();
  List<Task> _tasks = [];

  DateTime get selectedDate => _selectedDate;
  List<Task> get tasks => List.unmodifiable(_tasks);
  int get total => _tasks.length;
  int get done => _tasks.where((t) => t.isDone).length;
  double get progress => total == 0 ? 0.0 : done / total;
  String get selectedDateKey => _fmt.format(_selectedDate);

  TaskProvider() {
    loadTasks();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await loadTasks();
  }

  Future<void> loadTasks() async {
    _tasks = await _db.getTasksByDate(selectedDateKey);
    notifyListeners();
  }

  Future<void> addTask(String title, String? startTime, String? endTime) async {
    final task = await _db.insertTask(Task(
      title: title,
      date: selectedDateKey,
      startTime: startTime,
      endTime: endTime,
    ));
    _tasks.add(task);
    // Re-sort by start time
    _tasks.sort((a, b) {
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return a.startTime!.compareTo(b.startTime!);
    });
    notifyListeners();
  }

  Future<void> toggleTask(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final newVal = !_tasks[index].isDone;
    await _db.updateDone(id, newVal);
    _tasks[index] = _tasks[index].copyWith(isDone: newVal);
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
