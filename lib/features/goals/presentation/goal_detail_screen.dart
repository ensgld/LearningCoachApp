import 'package:flutter/material.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/shared/models/models.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late List<GoalTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.goal.tasks);
  }

  void _toggleTask(int index) {
    setState(() {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
    });
  }

  @override
  Widget build(BuildContext context) {
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
           Text("Alt Görevler", style: Theme.of(context).textTheme.titleLarge),
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
                   color: task.isCompleted ? Colors.grey : Colors.black87,
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
                 _tasks.add(GoalTask(title: "Yeni Görev ${_tasks.length + 1}"));
               });
             },
             icon: const Icon(Icons.add),
             label: const Text("Görev Ekle"),
           ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("İlerleme"),
            Text("%${(progress * 100).toInt()}"),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
          backgroundColor: Colors.grey.shade200,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
