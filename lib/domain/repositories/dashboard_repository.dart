import '../models/dashboard_metrics.dart';

abstract class DashboardRepository {
  Future<DashboardMetrics> getDashboardMetrics();
}
