import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/shared/data/providers.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  String? _selectedGoalId;
  double _duration = 25;

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navStudy)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
           Text(AppStrings.studyGoalLabel, style: Theme.of(context).textTheme.titleLarge),
           const SizedBox(height: 16),
           ...goals.map((goal) => Card(
             elevation: 0,
             shape: RoundedRectangleBorder(
               side: BorderSide(
                 color: _selectedGoalId == goal.id 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.transparent,
                 width: 2,
               ),
               borderRadius: BorderRadius.circular(16)
             ),
             child: ListTile(
               title: Text(goal.title),
               subtitle: Text(goal.description, maxLines: 1, overflow: TextOverflow.ellipsis),
               selected: _selectedGoalId == goal.id,
               onTap: () {
                 setState(() {
                   _selectedGoalId = goal.id;
                 });
               },
               trailing: IconButton(
                 icon: const Icon(Icons.info_outline),
                 onPressed: () => context.push('/goal-detail', extra: goal),
               ),
             ),
           )),
           const SizedBox(height: 32),
           Text(AppStrings.studyDurationLabel, style: Theme.of(context).textTheme.titleLarge),
           Slider(
             value: _duration,
             min: 5,
             max: 120,
             divisions: 23,
             label: '${_duration.round()} dk',
             onChanged: (val) => setState(() => _duration = val),
           ),
           Center(child: Text('${_duration.round()} dakika', style: Theme.of(context).textTheme.headlineSmall)),
           const SizedBox(height: 48),
           SizedBox(
             width: double.infinity,
             child: FilledButton.icon(
                onPressed: _selectedGoalId == null ? null : () {
                  context.go('/study/running');
                },
                icon: const Icon(Icons.timer),
                label: const Text(AppStrings.studyStartBtn),
             ),
           ),
        ],
      ),
    );
  }
}

