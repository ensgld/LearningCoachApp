import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:learning_coach/features/documents/presentation/document_chat_screen.dart';
import 'package:learning_coach/features/documents/presentation/document_detail_screen.dart';
import 'package:learning_coach/features/documents/presentation/documents_screen.dart';
import 'package:learning_coach/features/goals/presentation/goal_detail_screen.dart';
import 'package:learning_coach/features/kaizen/presentation/kaizen_checkin_screen.dart';
import 'package:learning_coach/features/profile/presentation/profile_screen.dart';
import 'package:learning_coach/features/study/presentation/session_finish_screen.dart';
import 'package:learning_coach/shared/models/models.dart'; // For Document type casting

import 'package:learning_coach/features/study/presentation/session_running_screen.dart';
import 'package:learning_coach/app/shell/app_shell.dart';
import 'package:learning_coach/features/home/presentation/home_screen.dart';
import 'package:learning_coach/features/study/presentation/session_summary_screen.dart';
import 'package:learning_coach/features/study/presentation/study_screen.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorStudy = GlobalKey<NavigatorState>(debugLabel: 'shellStudy');
final _shellNavigatorDocs = GlobalKey<NavigatorState>(debugLabel: 'shellDocs');
final _shellNavigatorProfile = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Study Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorStudy,
            routes: [
              GoRoute(
                path: '/study',
                builder: (context, state) => const StudyScreen(),
                routes: [
                  GoRoute(
                    path: 'running',
                    parentNavigatorKey: _rootNavigatorKey, // Hide bottom nav
                    builder: (context, state) => const SessionRunningScreen(),
                  ),
                  GoRoute(
                    path: 'quiz',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const SessionFinishScreen(),
                  ),
                  GoRoute(
                    path: 'summary',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const SessionSummaryScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Docs Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDocs,
            routes: [
              GoRoute(
                path: '/docs',
                builder: (context, state) => const DocumentsScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final doc = state.extra as Document;
                      return DocumentDetailScreen(document: doc);
                    },
                  ),
                  GoRoute(
                    path: 'chat',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                       final doc = state.extra as Document;
                       return DocumentChatScreen(document: doc);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Profile Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Global Routes (Full Screen / Modals)
      GoRoute(
        path: '/kaizen',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const KaizenCheckinScreen(),
      ),
      GoRoute(
        path: '/goal-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final goal = state.extra as Goal;
          return GoalDetailScreen(goal: goal);
        },
      ),
    ],
  );
}
