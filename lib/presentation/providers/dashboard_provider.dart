import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../data/repositories/api_dashboard_repository.dart';
import '../../domain/models/dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';

// Repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiDashboardRepository(apiClient);
});

// Dashboard metrics provider
final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDashboardMetrics();
});
