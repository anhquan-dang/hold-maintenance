import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/models/user.dart';
import 'presentation/providers/user_provider.dart';
import 'screens/add_asset_screen.dart';
import 'screens/add_support_ticket_screen.dart';
import 'screens/asset_detail_screen.dart';
import 'screens/asset_list_screen.dart';
import 'screens/change_password_force_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/department_asset_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/support_tickets_screen.dart';
import 'screens/user_management_screen.dart';
import 'utils/theme.dart';
import 'widgets/role_guard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: HoldMaintenanceApp()));
}

class HoldMaintenanceApp extends StatelessWidget {
  const HoldMaintenanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý tài sản CNTT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/change-password-force':
            final userId = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => ChangePasswordForceScreen(userId: userId),
            );
          case '/dashboard':
            return MaterialPageRoute(
              builder: (_) => const RoleGuard(
                allowedRoles: [UserRole.maintenanceManager, UserRole.departmentManager],
                allowITOnly: true,
                child: DashboardScreen(),
              ),
            );
          case '/users':
            return MaterialPageRoute(
              builder: (_) => const RoleGuard(
                allowedRoles: [UserRole.maintenanceManager],
                child: UserManagementScreen(),
              ),
            );
          case '/reports':
            return MaterialPageRoute(
              builder: (_) => const RoleGuard(
                allowedRoles: [UserRole.maintenanceManager, UserRole.departmentManager],
                allowITOnly: true,
                child: ReportsScreen(),
              ),
            );
          case '/assets':
            return MaterialPageRoute(
              builder: (_) => const RoleGuard(
                allowedRoles: [UserRole.maintenanceManager, UserRole.departmentManager],
                allowITOnly: true,
                child: AssetListScreen(),
              ),
            );
          case '/assets/add':
            return MaterialPageRoute(
              builder: (_) => const RoleGuard(
                allowedRoles: [UserRole.maintenanceManager, UserRole.departmentManager],
                allowITOnly: true,
                child: AddAssetScreen(),
              ),
            );
          case '/assets/detail':
            final assetId = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => RoleGuard(
                allowedRoles: UserRole.values,
                child: AssetDetailScreen(assetId: assetId),
              ),
            );
          case '/assets/department':
            final department = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => RoleGuard(
                allowedRoles: const [UserRole.departmentManager, UserRole.maintenanceManager],
                child: DepartmentAssetDetailScreen(department: department),
              ),
            );
          case '/support/tickets':
            return MaterialPageRoute(
              builder: (_) => RoleGuard(
                allowedRoles: UserRole.values,
                child: Consumer(
                  builder: (context, ref, _) {
                    final user = ref.watch(currentUserProvider).valueOrNull;
                    final isDeptManager = user != null &&
                        user.role == UserRole.departmentManager &&
                        user.department?.toLowerCase() != 'it';
                    return SupportTicketsScreen(isRequesterOnly: isDeptManager);
                  },
                ),
              ),
            );
          case '/my-tasks':
            return MaterialPageRoute(
              builder: (_) => const RoleGuard(
                allowedRoles: [UserRole.technician],
                child: SupportTicketsScreen(isMyTasksOnly: true),
              ),
            );
          case '/support/create':
            final assetId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => RoleGuard(
                allowedRoles: UserRole.values,
                child: AddSupportTicketScreen(preSelectedAssetId: assetId),
              ),
            );
          case '/scan':
            return MaterialPageRoute(
              builder: (_) => const RoleGuard(
                allowedRoles: UserRole.values,
                child: QrScanScreen(),
              ),
            );
          case '/notifications':
            return MaterialPageRoute(
              builder: (_) => const RoleGuard(
                allowedRoles: UserRole.values,
                child: NotificationsScreen(),
              ),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => const RoleGuard(
                allowedRoles: UserRole.values,
                child: ProfileScreen(),
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
