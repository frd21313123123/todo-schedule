import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/week_day_selector.dart';
import '../widgets/duration_picker.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? editTask;

  const AddTaskScreen({super.key, this.editTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late AnimationController _animController;

  DateTime? _dueDate;
  TimeOfDay? _startTime;
  Duration _duration = const Duration(minutes: 30);
  TaskPriority _priority = TaskPriority.medium;
  RepeatType _repeatType = RepeatType.none;
  List<int> _repeatDays = [];
  int _repeatWeekInterval = 1;
  String _categoryColor = '0xFF6C63FF';

  bool get _isEditing => widget.editTask != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    final task = widget.editTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    if (task != null) {
      _dueDate = task.dueDate;
      _startTime = task.startTime;
      _duration = task.duration;
      _priority = task.priority;
      _repeatType = task.repeatType;
      _repeatDays = List.from(task.repeatDays);
      _repeatWeekInterval = task.repeatWeekInterval ?? 1;
      _categoryColor = task.categoryColor;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Введите название задачи'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final provider = context.read<TaskProvider>();
    final task = TaskModel(
      id: widget.editTask?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      createdAt: widget.editTask?.createdAt,
      dueDate: _dueDate,
      startTime: _startTime,
      duration: _duration,
      isCompleted: widget.editTask?.isCompleted ?? false,
      priority: _priority,
      repeatType: _repeatType,
      repeatDays: _repeatDays,
      repeatWeekInterval: _repeatWeekInterval > 1 ? _repeatWeekInterval : null,
      categoryColor: _categoryColor,
    );

    if (_isEditing) {
      provider.updateTask(task);
    } else {
      provider.addTask(task);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать' : 'Новая задача'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () {
                context.read<TaskProvider>().deleteTask(widget.editTask!.id);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: TextField(
                controller: _titleController,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'Название задачи',
                  prefixIcon: Icon(Icons.edit_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 50),
              child: TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Описание (необязательно)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category color
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: _buildSectionTitle('Цвет категории'),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: _buildColorPicker(),
            ),
            const SizedBox(height: 24),

            // Due date
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 150),
              child: _buildDatePicker(context, theme),
            ),
            const SizedBox(height: 16),

            // Start time
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 200),
              child: _buildTimePicker(context, theme),
            ),
            const SizedBox(height: 24),

            // Duration
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 250),
              child: DurationPickerWidget(
                duration: _duration,
                onChanged: (d) => setState(() => _duration = d),
              ),
            ),
            const SizedBox(height: 24),

            // Priority
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 300),
              child: _buildPrioritySelector(theme),
            ),
            const SizedBox(height: 24),

            // Repeat
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 350),
              child: _buildRepeatSection(theme),
            ),
            const SizedBox(height: 32),

            // Save button
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 400),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _isEditing ? 'Сохранить' : 'Создать задачу',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 10,
      children: AppColors.categoryColors.map((color) {
        final hex = '0x${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}';
        final isSelected = _categoryColor == hex;
        return GestureDetector(
          onTap: () => setState(() => _categoryColor = hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(BuildContext context, ThemeData theme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.calendar_today_rounded,
            color: AppColors.primary, size: 20),
      ),
      title: Text(
        _dueDate != null
            ? DateFormat('d MMMM yyyy', 'ru').format(_dueDate!)
            : 'Выбрать дату',
        style: theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Дата начала / дедлайн',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
      ),
      trailing: _dueDate != null
          ? IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: () => setState(() => _dueDate = null),
            )
          : null,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (date != null) setState(() => _dueDate = date);
      },
    );
  }

  Widget _buildTimePicker(BuildContext context, ThemeData theme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.access_time_rounded,
            color: AppColors.accent, size: 20),
      ),
      title: Text(
        _startTime != null
            ? _startTime!.format(context)
            : 'Выбрать время начала',
        style: theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Время начала действия',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
      ),
      trailing: _startTime != null
          ? IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: () => setState(() => _startTime = null),
            )
          : null,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _startTime ?? TimeOfDay.now(),
        );
        if (time != null) setState(() => _startTime = time);
      },
    );
  }

  Widget _buildPrioritySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Приоритет'),
        const SizedBox(height: 12),
        Row(
          children: TaskPriority.values.map((p) {
            final isSelected = _priority == p;
            final color = _priorityColor(p);
            final label = _priorityLabel(p);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _priority = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRepeatSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Повторение'),
        const SizedBox(height: 12),
        // Repeat type selector
        Wrap(
          spacing: 8,
          children: RepeatType.values.map((r) {
            final isSelected = _repeatType == r;
            return GestureDetector(
              onTap: () => setState(() {
                _repeatType = r;
                if (r == RepeatType.none) _repeatDays = [];
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _repeatLabel(r),
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.hintColor,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Week day selector for weekly/custom
        if (_repeatType == RepeatType.weekly ||
            _repeatType == RepeatType.custom) ...[
          const SizedBox(height: 16),
          WeekDaySelector(
            selectedDays: _repeatDays,
            onChanged: (days) => setState(() => _repeatDays = days),
          ),
        ],
        // Week interval for custom
        if (_repeatType == RepeatType.custom) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Каждые ', style: theme.textTheme.bodyMedium),
              SizedBox(
                width: 60,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  controller: TextEditingController(
                      text: _repeatWeekInterval.toString()),
                  onChanged: (v) {
                    final val = int.tryParse(v);
                    if (val != null && val > 0) {
                      setState(() => _repeatWeekInterval = val);
                    }
                  },
                ),
              ),
              Text(' нед.', style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ],
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

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return 'Низкий';
      case TaskPriority.medium:
        return 'Средний';
      case TaskPriority.high:
        return 'Высокий';
    }
  }

  String _repeatLabel(RepeatType r) {
    switch (r) {
      case RepeatType.none:
        return 'Однократно';
      case RepeatType.daily:
        return 'Ежедневно';
      case RepeatType.weekly:
        return 'Еженедельно';
      case RepeatType.custom:
        return 'Настроить';
    }
  }
}
