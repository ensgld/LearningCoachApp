import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/widgets/reward_popups.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/services/gamification_service.dart';

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
    setState(() {
      final task = _tasks[index];
      final wasCompleted = task.isCompleted;
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      
      // Award gold for newly completed tasks
      if (!wasCompleted && _tasks[index].isCompleted) {
        final currentStats = ref.read(userStatsProvider);
        final newStats = GamificationService.awardTaskRewards(currentStats);
        ref.read(userStatsProvider.notifier).updateStats(newStats);
        
        // Show reward popup
        Future.delayed(const Duration(milliseconds: 300), () {
          showDialog(
            context: context,
            builder: (context) => TaskCompletionPopup(
              goldEarned: GamificationService.calculateTaskGoldReward(currentStats.stage),
              taskName: task.title,
              onClose: () => Navigator.of(context).pop(),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = _tasks.where((t) => t.isCompleted).length / (_tasks.isEmpty ? 1 : _tasks.length);

    return Scaffold(
      appBar: AppBar(title: Text(widget.goal.title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
           Text(widget.goal.description, style: Theme.of(context).textTheme.bodyLarge),
           const SizedBox(height: 24),
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
                   decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                   color: task.isCompleted ? scheme.onSurfaceVariant : scheme.onSurface,
                 ),
               ),
               controlAffinity: ListTileControlAffinity.leading,
               contentPadding: EdgeInsets.zero,
             );
           }),
           const SizedBox(height: 24),
           OutlinedButton.icon(
             onPressed: () {
               // Mock Add Task
               setState(() {
                 _tasks.add(GoalTask(title: 'Yeni Görev ${_tasks.length + 1}'));
               });
             },
             icon: const Icon(Icons.add),
             label: const Text('Görev Ekle'),
           ),
        ],
      ),
    );
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
}
