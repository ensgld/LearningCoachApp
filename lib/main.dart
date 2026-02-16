import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/app/router/app_router.dart';
import 'package:learning_coach/app/theme/app_theme.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  debugPrint("DotEnv loaded. API_BASE_URL: ${dotenv.env['API_BASE_URL']}");
  runApp(const ProviderScope(child: LearningCoachApp()));
}

class LearningCoachApp extends ConsumerWidget {
  const LearningCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: AppStrings.getAppName(locale),
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
