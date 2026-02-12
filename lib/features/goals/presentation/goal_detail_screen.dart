import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/services/gamification_service.dart';
import 'package:learning_coach/shared/widgets/reward_popups.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  late List<GoalTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.goal.tasks);
  }

  void _toggleTask(int index) async {
    final task = _tasks[index];
    final wasCompleted = task.isCompleted;
    final updatedTask = task.copyWith(isCompleted: !wasCompleted);

    setState(() {
      _tasks[index] = updatedTask;
    });

    try {
      await ref
          .read(apiGoalRepositoryProvider)
          .updateTask(widget.goal.id, updatedTask);

      // Award gold for newly completed tasks
      if (!wasCompleted && updatedTask.isCompleted) {
        final currentStats = ref.read(userStatsProvider);
        final newStats = GamificationService.awardTaskRewards(currentStats);
        ref.read(userStatsProvider.notifier).updateStats(newStats);

        // Show reward popup
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            showDialog<void>(
              context: context,
              builder: (context) => TaskCompletionPopup(
                goldEarned: GamificationService.calculateTaskGoldReward(
                  currentStats.stage,
                ),
                taskName: task.title,
                onClose: () => Navigator.of(context).pop(),
              ),
            );
          });
        }
      }
    } catch (e) {
      // Revert optimism
      setState(() {
        _tasks[index] = task;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress =
        _tasks.where((t) => t.isCompleted).length /
        (_tasks.isEmpty ? 1 : _tasks.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.title),
        actions: [
          IconButton(
            onPressed: _confirmDeleteGoal,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            widget.goal.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          // Total Study Time Display
          FutureBuilder<List<StudySession>>(
            future: ref.read(apiStudySessionRepositoryProvider).getSessions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final goalSessions = snapshot.data!
                  .where((s) => s.goalId == widget.goal.id)
                  .toList();

              if (goalSessions.isEmpty) {
                return const SizedBox.shrink();
              }

              final totalMinutes = goalSessions.fold<int>(
                0,
                (sum, session) =>
                    sum + (session.actualDurationSeconds ?? 0) ~/ 60,
              );

              final hours = totalMinutes ~/ 60;
              final minutes = totalMinutes % 60;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.tertiary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_rounded, color: scheme.tertiary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toplam Çalışma Süresi',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        Text(
                          '${hours}s ${minutes}dk',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: scheme.tertiary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          _buildProgressIndicator(progress),
          const SizedBox(height: 32),
          Text('Alt Görevler', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ..._tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            return CheckboxListTile(
              value: task.isCompleted,
              onChanged: (_) => _toggleTask(index),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.isCompleted
                      ? scheme.onSurfaceVariant
                      : scheme.onSurface,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              secondary: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditTaskDialog(task, index);
                  } else if (value == 'delete') {
                    _deleteTask(task, index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Sil', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add),
            label: const Text('Görev Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTaskDialog() async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Görev Ekle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Görev adı',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isEmpty) return;
              Navigator.pop(context);

              try {
                final updatedGoal = await ref
                    .read(apiGoalRepositoryProvider)
                    .addTask(widget.goal.id, title);
                setState(() {
                  _tasks = updatedGoal.tasks;
                });
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditTaskDialog(GoalTask task, int index) async {
    final controller = TextEditingController(text: task.title);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Düzenle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Görev adı',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isEmpty || title == task.title) {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(context);

              try {
                final updatedTask = task.copyWith(title: title);
                // Optimistic update
                setState(() {
                  _tasks[index] = updatedTask;
                });

                final updatedGoal = await ref
                    .read(apiGoalRepositoryProvider)
                    .updateTask(widget.goal.id, updatedTask);

                setState(() {
                  _tasks = updatedGoal.tasks;
                });
              } catch (e) {
                // Revert
                setState(() {
                  _tasks[index] = task;
                });
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(GoalTask task, int index) async {
    // Optimistic remove
    final previousTasks = List<GoalTask>.from(_tasks);
    setState(() {
      _tasks.removeAt(index);
    });

    try {
      final updatedGoal = await ref
          .read(apiGoalRepositoryProvider)
          .deleteTask(widget.goal.id, task.id);

      setState(() {
        _tasks = updatedGoal.tasks;
      });
    } catch (e) {
      // Revert
      setState(() {
        _tasks = previousTasks;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Widget _buildProgressIndicator(double progress) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('İlerleme'),
            Text('%${(progress * 100).toInt()}'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
          backgroundColor: scheme.surfaceContainerHighest,
          color: scheme.primary,
        ),
      ],
    );
  }

  Future<void> _confirmDeleteGoal() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hedef Silinsin mi?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await ref.read(apiGoalRepositoryProvider).deleteGoal(widget.goal.id);
      ref.invalidate(goalsProvider);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }
}
