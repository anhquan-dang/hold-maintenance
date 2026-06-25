import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user.dart';
import '../presentation/providers/user_provider.dart';
import '../utils/colors.dart';

class SidebarNav extends ConsumerWidget {
  final int currentIndex;

  const SidebarNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo / Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.devices_other_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'IT Asset Manager',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),

          // Nav Items
          Expanded(
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
                    _SidebarItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard_rounded,
                      label: 'Trang chủ',
                      isActive: currentIndex == 0,
                      onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                    ),
                  );
                  items.add(
                    _SidebarItem(
                      icon: Icons.inventory_2_outlined,
                      activeIcon: Icons.inventory_2_rounded,
                      label: 'Tài sản',
                      isActive: currentIndex == 1,
                      onTap: () => Navigator.pushReplacementNamed(context, '/assets'),
                    ),
                  );
                  items.add(
                    _SidebarItem(
                      icon: Icons.support_agent_outlined,
                      activeIcon: Icons.support_agent_rounded,
                      label: 'Hỗ trợ kỹ thuật',
                      isActive: currentIndex == 2,
                      onTap: () => Navigator.pushReplacementNamed(context, '/support/tickets'),
                    ),
                  );
                  if (isAdmin) {
                    items.add(
                      _SidebarItem(
                        icon: Icons.people_outline_rounded,
                        activeIcon: Icons.people_rounded,
                        label: 'Quản lý người dùng',
                        isActive: currentIndex == 4,
                        onTap: () => Navigator.pushReplacementNamed(context, '/users'),
                      ),
                    );
                  }
                  items.add(
                    _SidebarItem(
                      icon: Icons.analytics_outlined,
                      activeIcon: Icons.analytics_rounded,
                      label: 'Báo cáo thống kê',
                      isActive: currentIndex == 5,
                      onTap: () => Navigator.pushReplacementNamed(context, '/reports'),
                    ),
                  );
                } else if (isITSupport) {
                  items.add(
                    _SidebarItem(
                      icon: Icons.task_outlined,
                      activeIcon: Icons.task_rounded,
                      label: 'Công việc của tôi',
                      isActive: currentIndex == 10,
                      onTap: () => Navigator.pushReplacementNamed(context, '/my-tasks'),
                    ),
                  );
                  items.add(
                    _SidebarItem(
                      icon: Icons.assignment_outlined,
                      activeIcon: Icons.assignment_rounded,
                      label: 'Tất cả yêu cầu',
                      isActive: currentIndex == 2,
                      onTap: () => Navigator.pushReplacementNamed(context, '/support/tickets'),
                    ),
                  );
                } else if (isDeptManager) {
                  items.add(
                    _SidebarItem(
                      icon: Icons.business_outlined,
                      activeIcon: Icons.business_rounded,
                      label: 'Tài sản phòng ban',
                      isActive: currentIndex == 12,
                      onTap: () => Navigator.pushReplacementNamed(context, '/assets/department'),
                    ),
                  );
                  items.add(
                    _SidebarItem(
                      icon: Icons.support_agent_outlined,
                      activeIcon: Icons.support_agent_rounded,
                      label: 'Yêu cầu hỗ trợ',
                      isActive: currentIndex == 2,
                      onTap: () => Navigator.pushReplacementNamed(context, '/support/tickets'),
                    ),
                  );
                }

                items.add(
                  _SidebarItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Tài khoản',
                    isActive: currentIndex == 3,
                    onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
                  ),
                );

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: items,
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),

          // User Profile Card at Bottom
          userAsync.maybeWhen(
            data: (user) {
              if (user == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.roleLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textSecondary),
                      onPressed: () async {
                        await ref.read(userRepositoryProvider).logout();
                        ref.invalidate(currentUserProvider);
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final defaultColor = AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : (_isHovered ? AppColors.muted : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isActive ? widget.activeIcon : widget.icon,
                  color: widget.isActive ? activeColor : defaultColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                      color: widget.isActive ? AppColors.textPrimary : defaultColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
