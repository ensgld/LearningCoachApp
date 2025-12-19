import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/app/router/app_router.dart';
import 'package:learning_coach/app/theme/app_theme.dart';
import 'package:learning_coach/core/constants/app_strings.dart';

void main() {
  runApp(const ProviderScope(child: LearningCoachApp()));
}

class LearningCoachApp extends ConsumerWidget {
  const LearningCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
