import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/notification_provider.dart';
import '../utils/colors.dart';
import 'bottom_nav.dart';
import 'sidebar_nav.dart';

class SaasLayout extends ConsumerWidget {
  final int currentIndex;
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const SaasLayout({
    super.key,
    required this.currentIndex,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    if (isDesktop) {
      final unreadCount = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

      return Scaffold(
        body: Row(
          children: [
            SidebarNav(currentIndex: currentIndex),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Desktop Header
                    Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: const BoxDecoration(
                        color: AppColors.card,
                        border: Border(
                          bottom: BorderSide(color: AppColors.border, width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Row(
                            children: [
                              if (actions != null) ...[
                                ...actions!,
                                const SizedBox(width: 12),
                              ],
                              // Notification Icon Button
                              IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/notifications');
                                },
                                icon: Badge(
                                  isLabelVisible: unreadCount > 0,
                                  label: Text(unreadCount.toString()),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.textSecondary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Main Content Area
                    Expanded(
                      child: ClipRRect(
                        child: body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile View
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: body,
        bottomNavigationBar: BottomNav(currentIndex: currentIndex),
        floatingActionButton: floatingActionButton,
      );
    }
  }
}
