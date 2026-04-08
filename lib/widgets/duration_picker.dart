import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DurationPickerWidget extends StatelessWidget {
  final Duration duration;
  final ValueChanged<Duration> onChanged;

  const DurationPickerWidget({
    super.key,
    required this.duration,
    required this.onChanged,
  });

  static const _presets = [15, 30, 45, 60, 90, 120, 180];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Длительность',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets.map((minutes) {
            final isSelected = duration.inMinutes == minutes;
            final label = minutes >= 60
                ? '${minutes ~/ 60}ч${minutes % 60 > 0 ? ' ${minutes % 60}м' : ''}'
                : '${minutes}м';
            return GestureDetector(
              onTap: () => onChanged(Duration(minutes: minutes)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  label,
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
        const SizedBox(height: 12),
        // Custom slider
        Row(
          children: [
            Text('Или:', style: theme.textTheme.bodySmall),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primary.withOpacity(0.15),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.1),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: duration.inMinutes.toDouble().clamp(5, 480),
                  min: 5,
                  max: 480,
                  divisions: 95,
                  label: _formatDuration(duration),
                  onChanged: (v) =>
                      onChanged(Duration(minutes: v.round())),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                _formatDuration(duration),
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0 && m > 0) return '${h}ч ${m}м';
    if (h > 0) return '${h}ч';
    return '${m}м';
  }
}
