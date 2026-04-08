import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/animated_task_tile.dart';
import '../widgets/stats_card.dart';
import '../utils/page_transitions.dart';
import 'add_task_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayTasks = provider.tasksForDate(today);
    final completedCount = todayTasks.where((t) => t.isCompleted).length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE', 'ru').format(today),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        Text(
                          DateFormat('d MMMM', 'ru').format(today),
                          style: theme.appBarTheme.titleTextStyle,
                        ),
                      ],
                    ),
                  ),
                  FadeInRight(
                    duration: const Duration(milliseconds: 500),
                    child: IconButton(
                      onPressed: () {
                        provider.toggleTheme();
                      },
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => RotationTransition(
                          turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: Icon(
                          provider.themeMode == ThemeMode.dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          key: ValueKey(provider.themeMode),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: StatsCard(
                  totalTasks: todayTasks.length,
                  completedTasks: completedCount,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: FadeInLeft(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Задачи на сегодня',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          if (todayTasks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: FadeIn(
                duration: const Duration(milliseconds: 600),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 80,
                        color: theme.hintColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет задач на сегодня',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Нажмите + чтобы добавить',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = todayTasks[index];
                  return AnimatedTaskTile(
                    task: task,
                    index: index,
                    onTap: () {
                      Navigator.of(context).push(
                        SlidePageRoute(
                          page: AddTaskScreen(editTask: task),
                        ),
                      );
                    },
                  );
                },
                childCount: todayTasks.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
