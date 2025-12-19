import 'package:flutter/material.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/features/home/presentation/widgets/home_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeGreeting)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TodayPlanCard(),
          SizedBox(height: 16),
          QuickKaizenCard(),
          SizedBox(height: 16),
          ProgressSummaryCard(),
          SizedBox(height: 16),
          CoachTipCard(),
        ],
      ),
    );
  }
}
