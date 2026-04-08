import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import 'add_task_screen.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key});

  static const _dayNames = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];
  static const _dayShort = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final tasksByDay = provider.tasksByWeekday;
    final today = DateTime.now().weekday;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'Недельное расписание',
                  style: theme.appBarTheme.titleTextStyle,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final day = index + 1;
                final tasks = tasksByDay[day] ?? [];
                final isToday = day == today;

                return FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 60 * index),
                  child: _WeekDayCard(
                    dayName: _dayNames[index],
                    dayShort: _dayShort[index],
                    tasks: tasks,
                    isToday: isToday,
                    onTaskTap: (task) {
                      Navigator.of(context).push(
                        SlidePageRoute(
                          page: AddTaskScreen(editTask: task),
                        ),
                      );
                    },
                  ),
                );
              },
              childCount: 7,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _WeekDayCard extends StatelessWidget {
  final String dayName;
  final String dayShort;
  final List<TaskModel> tasks;
  final bool isToday;
  final ValueChanged<TaskModel> onTaskTap;

  const _WeekDayCard({
    required this.dayName,
    required this.dayShort,
    required this.tasks,
    required this.isToday,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            dayShort,
            style: TextStyle(
              color: isToday ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          dayName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isToday ? AppColors.primary : null,
          ),
        ),
        subtitle: Text(
          '${tasks.length} задач',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
        initiallyExpanded: isToday,
        children: [
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Нет повторяющихся задач',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            )
          else
            ...tasks.map((task) {
              final color = Color(int.parse(task.categoryColor));
              return ListTile(
                onTap: () => onTaskTap(task),
                leading: Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                title: Text(
                  task.title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                subtitle: Row(
                  children: [
                    if (task.startTime != null) ...[
                      Icon(Icons.access_time_rounded,
                          size: 12, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        task.startTimeFormatted,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(Icons.timer_outlined,
                        size: 12, color: theme.hintColor),
                    const SizedBox(width: 4),
                    Text(task.durationFormatted,
                        style: theme.textTheme.bodySmall),
                  ],
                ),
                trailing: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _priorityColor(task.priority),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }
}
