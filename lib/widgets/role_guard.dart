import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user.dart';
import '../presentation/providers/user_provider.dart';
import '../utils/colors.dart';

class RoleGuard extends ConsumerWidget {
  final Widget child;
  final List<UserRole> allowedRoles;
  final bool allowITOnly;
  final bool allowNonITOnly;

  const RoleGuard({
    required this.child,
    required this.allowedRoles,
    this.allowITOnly = false,
    this.allowNonITOnly = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          // Redirect to login if not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Enforce forced password reset redirection
        if (user.requirePasswordChange) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/change-password-force', arguments: user.id);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        bool isAuthorized = allowedRoles.contains(user.role);
        final isIT = user.department?.toLowerCase() == 'it';

        if (isAuthorized) {
          if (allowITOnly && !isIT) {
            isAuthorized = false;
          }
          if (allowNonITOnly && isIT) {
            isAuthorized = false;
          }
        }

        if (isAuthorized) {
          return child;
        }

        // Access Denied Screen
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.gpp_bad_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Truy cập bị từ chối',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bạn không có quyền truy cập chức năng này.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to their specific default home route
                      String homeRoute = '/login';
                      if (user.role == UserRole.maintenanceManager) {
                        homeRoute = '/dashboard';
                      } else if (user.role == UserRole.technician) {
                        homeRoute = '/support/tickets'; // IT Support default is Tickets list
                      } else if (user.role == UserRole.departmentManager) {
                        if (isIT) {
                          homeRoute = '/dashboard';
                        } else {
                          homeRoute = '/assets/department'; // Department Manager default
                        }
                      }
                      Navigator.pushReplacementNamed(context, homeRoute);
                    },
                    child: const Text('Quay lại trang chính'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
