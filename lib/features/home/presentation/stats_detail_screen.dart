import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/shared/data/providers.dart';

class StatsDetailScreen extends ConsumerWidget {
  const StatsDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final dailyStatsAsync = ref.watch(dailyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getAdventureLog(locale)),
        centerTitle: true,
      ),
      body: dailyStatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (stats) {
          if (stats.isEmpty) {
            return const Center(child: Text('No stats available yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: stats.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = stats[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    child: Text('${item.sessions}x'),
                  ),
                  title: Text(
                    item.date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${AppStrings.getTotalMinutes(locale)}: ${item.minutes}',
                  ),
                  trailing: Icon(
                    Icons.bar_chart,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
