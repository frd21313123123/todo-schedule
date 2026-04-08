import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

enum RepeatType { none, daily, weekly, custom }

class TaskModel {
  final String id;
  String title;
  String description;
  DateTime createdAt;
  DateTime? dueDate;
  TimeOfDay? startTime;
  Duration duration;
  bool isCompleted;
  TaskPriority priority;
  RepeatType repeatType;
  List<int> repeatDays; // 1=Mon ... 7=Sun
  int? repeatWeekInterval; // every N weeks
  String categoryColor; // hex color string

  TaskModel({
    String? id,
    required this.title,
    this.description = '',
    DateTime? createdAt,
    this.dueDate,
    this.startTime,
    this.duration = const Duration(minutes: 30),
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.repeatType = RepeatType.none,
    this.repeatDays = const [],
    this.repeatWeekInterval,
    this.categoryColor = '0xFF6C63FF',
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'startTimeHour': startTime?.hour,
      'startTimeMinute': startTime?.minute,
      'durationMinutes': duration.inMinutes,
      'isCompleted': isCompleted,
      'priority': priority.index,
      'repeatType': repeatType.index,
      'repeatDays': repeatDays,
      'repeatWeekInterval': repeatWeekInterval,
      'categoryColor': categoryColor,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      startTime: json['startTimeHour'] != null
          ? TimeOfDay(
              hour: json['startTimeHour'] as int,
              minute: json['startTimeMinute'] as int,
            )
          : null,
      duration: Duration(minutes: json['durationMinutes'] as int? ?? 30),
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values[json['priority'] as int? ?? 1],
      repeatType: RepeatType.values[json['repeatType'] as int? ?? 0],
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      repeatWeekInterval: json['repeatWeekInterval'] as int?,
      categoryColor: json['categoryColor'] as String? ?? '0xFF6C63FF',
    );
  }

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? startTime,
    Duration? duration,
    bool? isCompleted,
    TaskPriority? priority,
    RepeatType? repeatType,
    List<int>? repeatDays,
    int? repeatWeekInterval,
    String? categoryColor,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      repeatWeekInterval: repeatWeekInterval ?? this.repeatWeekInterval,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  /// Check if this task is scheduled for a given date
  bool isScheduledFor(DateTime date) {
    if (repeatType == RepeatType.none) {
      if (dueDate == null) return false;
      return dueDate!.year == date.year &&
          dueDate!.month == date.month &&
          dueDate!.day == date.day;
    }

    if (repeatType == RepeatType.daily) {
      if (dueDate != null && date.isBefore(dueDate!)) return false;
      return true;
    }

    if (repeatType == RepeatType.weekly) {
      if (dueDate != null && date.isBefore(dueDate!)) return false;
      return repeatDays.contains(date.weekday);
    }

    if (repeatType == RepeatType.custom) {
      if (dueDate == null) return false;
      if (date.isBefore(dueDate!)) return false;
      if (!repeatDays.contains(date.weekday)) return false;
      if (repeatWeekInterval != null && repeatWeekInterval! > 1) {
        final weeksDiff =
            date.difference(dueDate!).inDays ~/ 7;
        return weeksDiff % repeatWeekInterval! == 0;
      }
      return true;
    }

    return false;
  }

  /// End time based on start + duration
  TimeOfDay? get endTime {
    if (startTime == null) return null;
    final totalMinutes =
        startTime!.hour * 60 + startTime!.minute + duration.inMinutes;
    return TimeOfDay(hour: (totalMinutes ~/ 60) % 24, minute: totalMinutes % 60);
  }

  String get startTimeFormatted => startTime?.formatted() ?? '';
  String get endTimeFormatted => endTime?.formatted() ?? '';

  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) return '${hours}ч ${minutes}мин';
    if (hours > 0) return '${hours}ч';
    return '${minutes}мин';
  }
}

extension TimeOfDayFormat on TimeOfDay {
  String formatted() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
