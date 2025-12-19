import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';

// --- Today Plan Card ---
class TodayPlanCard extends StatelessWidget {
  const TodayPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.todayPlanTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Bugün: 1 Seans hedefi • 45 dk'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/study'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(AppStrings.sessionStartBtn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Quick Kaizen Card ---
class QuickKaizenCard extends StatelessWidget {
  const QuickKaizenCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.bolt, color: Colors.orange),
        ),
        title: const Text(AppStrings.quickKaizenTitle),
        subtitle: const Text(AppStrings.quickKaizenSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push('/kaizen');
        },
      ),
    );
  }
}

// --- Progress Summary Card ---
class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.weeklyProgress,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, '120', 'dk Toplam'),
                _buildDivider(),
                _buildStatItem(context, '4', 'Seans'),
                _buildDivider(),
                _buildStatItem(context, '85%', 'Ort. Skor'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() =>
      Container(height: 24, width: 1, color: Colors.grey.shade300);

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// --- Coach Tip Card ---
class CoachTipCard extends StatelessWidget {
  const CoachTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.indigo.shade50,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.indigo),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.coachTipTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pomodoro tekniği ile dikkatinizi canlı tutun.',
                    style: TextStyle(color: Colors.indigo.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
