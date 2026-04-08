import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_task_tile.dart';
import '../utils/page_transitions.dart';
import 'add_task_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final selectedDate = provider.selectedDate;
    final dayTasks = provider.tasksForDate(selectedDate);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'Расписание',
                  style: theme.appBarTheme.titleTextStyle,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Card(
                margin: const EdgeInsets.all(16),
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2035),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  locale: 'ru',
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                  onDaySelected: (selected, focused) {
                    provider.selectDate(selected);
                    setState(() => _focusedDay = focused);
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    markerSize: 5,
                    markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonDecoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    formatButtonTextStyle:
                        const TextStyle(color: AppColors.primary, fontSize: 12),
                    titleCentered: true,
                  ),
                  eventLoader: (day) {
                    final count = provider.taskCountForDate(day);
                    return List.generate(count.clamp(0, 3), (_) => '');
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Text(
                    DateFormat('d MMMM, EEEE', 'ru').format(selectedDate),
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '${dayTasks.length} задач',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (dayTasks.isEmpty)
            SliverToBoxAdapter(
              child: FadeIn(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Нет задач на этот день',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = dayTasks[index];
                  return AnimatedTaskTile(
                    task: task,
                    index: index,
                    onTap: () {
                      Navigator.of(context).push(
                        SlidePageRoute(
                            page: AddTaskScreen(editTask: task)),
                      );
                    },
                  );
                },
                childCount: dayTasks.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
