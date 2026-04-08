import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  ThemeMode _themeMode = ThemeMode.system;
  DateTime _selectedDate = DateTime.now();

  List<TaskModel> get tasks => _tasks;
  ThemeMode get themeMode => _themeMode;
  DateTime get selectedDate => _selectedDate;

  // --- Persistence ---

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _tasks = decoded.map((e) => TaskModel.fromJson(e)).toList();
    }
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', encoded);
  }

  // --- Theme ---

  void toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    notifyListeners();
  }

  // --- Date selection ---

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // --- CRUD ---

  void addTask(TaskModel task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(TaskModel updated) {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void toggleComplete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveTasks();
      notifyListeners();
    }
  }

  // --- Queries ---

  List<TaskModel> tasksForDate(DateTime date) {
    return _tasks.where((t) => t.isScheduledFor(date)).toList()
      ..sort((a, b) {
        if (a.startTime == null && b.startTime == null) return 0;
        if (a.startTime == null) return 1;
        if (b.startTime == null) return -1;
        final aMin = a.startTime!.hour * 60 + a.startTime!.minute;
        final bMin = b.startTime!.hour * 60 + b.startTime!.minute;
        return aMin.compareTo(bMin);
      });
  }

  List<TaskModel> get todayTasks => tasksForDate(DateTime.now());

  List<TaskModel> get incompleteTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  Map<int, List<TaskModel>> get tasksByWeekday {
    final map = <int, List<TaskModel>>{};
    for (int i = 1; i <= 7; i++) {
      map[i] = _tasks
          .where((t) =>
              t.repeatType == RepeatType.weekly && t.repeatDays.contains(i) ||
              t.repeatType == RepeatType.daily ||
              t.repeatType == RepeatType.custom && t.repeatDays.contains(i))
          .toList();
    }
    return map;
  }

  int taskCountForDate(DateTime date) {
    return _tasks.where((t) => t.isScheduledFor(date)).length;
  }

  double completionRateForDate(DateTime date) {
    final dayTasks = tasksForDate(date);
    if (dayTasks.isEmpty) return 0;
    return dayTasks.where((t) => t.isCompleted).length / dayTasks.length;
  }
}
