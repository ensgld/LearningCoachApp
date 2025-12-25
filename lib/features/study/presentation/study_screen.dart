import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'dart:ui';

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.navStudy,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.8,
                  ),
            ),
            Text(
              'Bugün hangi hedefe çalışalım?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // Goal Selection Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primaryContainer.withOpacity(0.3),
                  scheme.secondaryContainer.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: scheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    AppStrings.studyGoalLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Goals List
          ...goals.map((goal) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: _selectedGoalId == goal.id
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _selectedGoalId != goal.id ? Colors.white : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedGoalId == goal.id
                          ? const Color(0xFF6366F1).withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: _selectedGoalId == goal.id ? 16 : 8,
                      offset: Offset(0, _selectedGoalId == goal.id ? 8 : 4),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedGoalId = goal.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _selectedGoalId == goal.id
                                  ? Colors.white.withOpacity(0.2)
                                  : scheme.primaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.bookmark_rounded,
                              color: _selectedGoalId == goal.id
                                  ? Colors.white
                                  : scheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedGoalId == goal.id
                                            ? Colors.white
                                            : scheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  goal.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: _selectedGoalId == goal.id
                                            ? Colors.white.withOpacity(0.9)
                                            : scheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline_rounded,
                              color: _selectedGoalId == goal.id
                                  ? Colors.white
                                  : scheme.onSurfaceVariant,
                            ),
                            onPressed: () => context.push('/goal-detail', extra: goal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 32),
          
          // Duration Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: scheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.timer_rounded,
                        color: scheme.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      AppStrings.studyDurationLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.secondary.withOpacity(0.15),
                          scheme.tertiary.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_duration.round()} dakika',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                            letterSpacing: -1,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 8,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                    activeTrackColor: scheme.primary,
                    inactiveTrackColor: scheme.primary.withOpacity(0.2),
                    thumbColor: scheme.primary,
                    overlayColor: scheme.primary.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _duration,
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: '${_duration.round()} dk',
                    onChanged: (val) => setState(() => _duration = val),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Start Button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _selectedGoalId == null
                    ? null
                    : () {
                        context.go('/study/running');
                      },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        color: _selectedGoalId == null
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.studyStartBtn,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedGoalId == null
                              ? Colors.white.withOpacity(0.5)
                              : Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

