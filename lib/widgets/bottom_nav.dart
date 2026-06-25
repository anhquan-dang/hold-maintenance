import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user.dart';
import '../presentation/providers/user_provider.dart';
import '../utils/colors.dart';

class BottomNav extends ConsumerWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: userAsync.maybeWhen(
            data: (user) {
              if (user == null) return const SizedBox.shrink();

              final isIT = user.department?.toLowerCase() == 'it';
              final isAdmin = user.role == UserRole.maintenanceManager;
              final isITManager = user.role == UserRole.departmentManager && isIT;
              final isITSupport = user.role == UserRole.technician;
              final isDeptManager = user.role == UserRole.departmentManager && !isIT;

              final List<Widget> items = [];

              if (isAdmin || isITManager) {
                items.add(
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Trang chủ',
                    isActive: currentIndex == 0,
                    onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                  ),
                );
                items.add(
                  _NavItem(
                    icon: Icons.inventory_2_rounded,
                    label: 'Tài sản',
                    isActive: currentIndex == 1,
                    onTap: () => Navigator.pushReplacementNamed(context, '/assets'),
                  ),
                );
                items.add(
                  _NavItem(
                    icon: Icons.support_agent_rounded,
                    label: 'Hỗ trợ',
                    isActive: currentIndex == 2,
                    onTap: () => Navigator.pushReplacementNamed(context, '/support/tickets'),
                  ),
                );
                if (isAdmin) {
                  items.add(
                    _NavItem(
                      icon: Icons.people_rounded,
                      label: 'N.dùng',
                      isActive: currentIndex == 4,
                      onTap: () => Navigator.pushReplacementNamed(context, '/users'),
                    ),
                  );
                } else {
                  items.add(
                    _NavItem(
                      icon: Icons.analytics_rounded,
                      label: 'Báo cáo',
                      isActive: currentIndex == 5,
                      onTap: () => Navigator.pushReplacementNamed(context, '/reports'),
                    ),
                  );
                }
              } else if (isITSupport) {
                items.add(
                  _NavItem(
                    icon: Icons.task_rounded,
                    label: 'C.việc',
                    isActive: currentIndex == 10,
                    onTap: () => Navigator.pushReplacementNamed(context, '/my-tasks'),
                  ),
                );
                items.add(
                  _NavItem(
                    icon: Icons.assignment_rounded,
                    label: 'Yêu cầu',
                    isActive: currentIndex == 2,
                    onTap: () => Navigator.pushReplacementNamed(context, '/support/tickets'),
                  ),
                );
              } else if (isDeptManager) {
                items.add(
                  _NavItem(
                    icon: Icons.business_rounded,
                    label: 'T.sản PB',
                    isActive: currentIndex == 12,
                    onTap: () => Navigator.pushReplacementNamed(context, '/assets/department'),
                  ),
                );
                items.add(
                  _NavItem(
                    icon: Icons.support_agent_rounded,
                    label: 'Hỗ trợ',
                    isActive: currentIndex == 2,
                    onTap: () => Navigator.pushReplacementNamed(context, '/support/tickets'),
                  ),
                );
              }

              items.add(
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Tài khoản',
                  isActive: currentIndex == 3,
                  onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
                ),
              );

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: items,
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
