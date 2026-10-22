import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventTasksSection extends HookConsumerWidget {
  const EventTasksSection({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final notifier = ref.read(eventsProvider.notifier);
    final controller = useTextEditingController();
    final progress = event.tasks.isEmpty
        ? 0.0
        : event.doneTaskCount / event.tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tasks',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${event.doneTaskCount}/${event.tasks.length}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const GutterSmall(),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colors.surfaceContainerHighest,
                    color: AppColors.primary,
                  ),
                ),
                const Gutter(),
                if (event.tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No tasks yet — add your first checklist item.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final task in event.tasks) ...[
                    _TaskTile(
                      task: task,
                      onToggle: () => notifier.toggleTask(event.id, task.id),
                      onEdit: () => _editTask(context, notifier, task),
                      onDelete: () => notifier.deleteTask(event.id, task.id),
                    ),
                    const GutterSmall(),
                  ],
                const GutterSmall(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Add a task…',
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          isDense: true,
                        ),
                        onSubmitted: (value) {
                          notifier.addTask(event.id, value);
                          controller.clear();
                        },
                      ),
                    ),
                    const GutterSmall(),
                    IconButton.filled(
                      onPressed: () {
                        notifier.addTask(event.id, controller.text);
                        controller.clear();
                      },
                      icon: const Icon(LucideIcons.plus, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editTask(
    BuildContext context,
    EventsNotifier notifier,
    EventTask task,
  ) async {
    final controller = TextEditingController(text: task.title);
    final result = await showAppGlassDialog<String>(
      context: context,
      builder: (ctx) {
        return AppGlassDialog(
          title: const Text('Edit task'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Save'),
            ),
          ],
          child: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Task'),
          ),
        );
      },
    );
    if (result != null) notifier.updateTaskTitle(event.id, task.id, result);
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final EventTask task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: Row(
            children: [
              Checkbox(value: task.isDone, onChanged: (_) => onToggle()),
              Expanded(
                child: Text(
                  task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone
                        ? colors.onSurfaceVariant
                        : colors.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(
                  LucideIcons.pencil,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
