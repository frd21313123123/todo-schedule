import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../providers/task_provider.dart';
import '../widgets/animated_fab.dart';
import '../widgets/stats_card.dart';
import '../utils/page_transitions.dart';
import 'today_screen.dart';
import 'schedule_screen.dart';
import 'weekly_screen.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    TodayScreen(),
    ScheduleScreen(),
    WeeklyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      floatingActionButton: AnimatedFab(
        onPressed: () {
          Navigator.of(context).push(
            SlidePageRoute(page: const AddTaskScreen()),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_rounded),
            selectedIcon: Icon(Icons.today_rounded),
            label: 'Сегодня',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Расписание',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_week_rounded),
            selectedIcon: Icon(Icons.view_week_rounded),
            label: 'Неделя',
          ),
        ],
      ),
    );
  }
}
