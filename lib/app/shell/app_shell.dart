import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/features/chat/presentation/chat_screen.dart';
import 'package:learning_coach/shared/widgets/document_upload_options.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              backgroundColor: scheme.surface.withValues(alpha: 0.85),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: AppStrings.getNavHome(ref.watch(localeProvider)),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.timer_outlined),
                  selectedIcon: const Icon(Icons.timer_rounded),
                  label: AppStrings.getNavStudy(ref.watch(localeProvider)),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.description_outlined),
                  selectedIcon: const Icon(Icons.description_rounded),
                  label: AppStrings.getNavDocs(ref.watch(localeProvider)),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: AppStrings.getNavProfile(ref.watch(localeProvider)),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: navigationShell.currentIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                showDocumentUploadOptions(
                  context: context,
                  ref: ref,
                  locale: ref.watch(localeProvider),
                );
              },
              backgroundColor: const Color(0xFF6366F1),
              elevation: 8,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const ChatScreen(),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
