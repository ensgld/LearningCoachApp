import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/app/shell/app_shell.dart';
import 'package:learning_coach/features/auth/application/auth_controller.dart';
import 'package:learning_coach/features/auth/presentation/screens/auth_welcome_screen.dart';
import 'package:learning_coach/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:learning_coach/features/auth/presentation/screens/login_screen.dart';
import 'package:learning_coach/features/auth/presentation/screens/signup_screen.dart';
// Feature imports
import 'package:learning_coach/features/documents/presentation/document_chat_screen.dart';
import 'package:learning_coach/features/documents/presentation/document_detail_screen.dart';
import 'package:learning_coach/features/documents/presentation/documents_screen.dart';
import 'package:learning_coach/features/goals/presentation/goal_detail_screen.dart';
import 'package:learning_coach/features/home/presentation/home_screen.dart';
import 'package:learning_coach/features/kaizen/presentation/kaizen_checkin_screen.dart';
import 'package:learning_coach/features/profile/presentation/profile_screen.dart';
import 'package:learning_coach/features/study/presentation/session_finish_screen.dart';
import 'package:learning_coach/features/study/presentation/session_running_screen.dart';
import 'package:learning_coach/features/study/presentation/session_summary_screen.dart';
import 'package:learning_coach/features/study/presentation/study_screen.dart';
import 'package:learning_coach/shared/models/models.dart'; // For Document type casting
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorStudy = GlobalKey<NavigatorState>(
  debugLabel: 'shellStudy',
);
final _shellNavigatorDocs = GlobalKey<NavigatorState>(debugLabel: 'shellDocs');
final _shellNavigatorProfile = GlobalKey<NavigatorState>(
  debugLabel: 'shellProfile',
);

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    // İlk açılışta welcome ekranı
    initialLocation: '/welcome',

    /// Route Guard (Mock Auth)
    ///
    /// Kullanıcı giriş durumuna göre sayfa erişimini kontrol eder.
    ///
    /// Kurallar:
    /// 1. Giriş yapmadıysa (/welcome, /auth/*  dışındaki tüm sayfalar) → /welcome'a yönlendir
    /// 2. Giriş yaptıysa (welcome veya auth sayfalarında) → /home'a yönlendir
    redirect: (context, state) {
      // Auth state'i kontrol et
      final isLoggedIn = ref.read(authControllerProvider);

      // Auth route'larını kontrol et
      final isAuthRoute =
          state.uri.path == '/welcome' || state.uri.path.startsWith('/auth');

      // Giriş yapmadıysa ve auth route'unda değilse → welcome'a yönlendir
      if (!isLoggedIn && !isAuthRoute) {
        return '/welcome';
      }

      // Giriş yaptıysa ve auth route'undaysa → home'a yönlendir
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      // Diğer durumlar: redirect yok
      return null;
    },

    routes: [
      // ========================================
      // AUTH ROUTES (Giriş yapmadan erişilebilir)
      // ========================================

      /// Welcome Screen
      /// İlk açılış ekranı - Giriş Yap / Kayıt Ol seçenekleri
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const AuthWelcomeScreen(),
      ),

      /// Login Screen
      /// Email/şifre ve sosyal giriş
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),

      /// Signup Screen
      /// Yeni kullanıcı kaydı
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      /// Forgot Password Screen
      /// Şifre sıfırlama (mock)
      GoRoute(
        path: '/auth/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ========================================
      // APP ROUTES (Giriş yapılması gerekir)
      // ========================================
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
