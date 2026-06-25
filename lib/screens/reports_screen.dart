import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/dashboard_provider.dart';
import '../presentation/widgets/error_state.dart';
import '../presentation/widgets/loading_state.dart';
import '../presentation/widgets/statistic_card.dart';
import '../utils/colors.dart';
import '../widgets/saas_layout.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return SaasLayout(
      currentIndex: 5, // Reports screen index
      title: 'Báo cáo thống kê',
      body: metricsAsync.when(
        data: (metrics) {
          final summaryGrid = GridView.count(
            crossAxisCount: isDesktop ? 5 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isDesktop ? 1.4 : 1.3,
            children: [
              StatisticCard(
                title: 'Tổng số tài sản',
                value: metrics.totalAssets.toString(),
                icon: Icons.inventory_2_outlined,
                color: AppColors.primary,
              ),
              StatisticCard(
                title: 'Đang hoạt động',
                value: metrics.assetsInUse.toString(),
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
              StatisticCard(
                title: 'Đang sửa chữa',
                value: metrics.assetsInMaintenance.toString(),
                icon: Icons.handyman_outlined,
                color: AppColors.warning,
              ),
              StatisticCard(
                title: 'Yêu cầu đang mở',
                value: metrics.openTickets.toString(),
                icon: Icons.assignment_late_outlined,
                color: AppColors.orange,
              ),
              StatisticCard(
                title: 'Yêu cầu đã xong',
                value: metrics.completedTickets.toString(),
                icon: Icons.task_alt_outlined,
                color: Colors.teal,
              ),
            ],
          );

          final deptAllocationList = Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phân bổ theo phòng ban',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  if (metrics.assetsByDepartment.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Chưa có thông tin phân bổ.', style: TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    ...metrics.assetsByDepartment.entries.map((entry) {
                      final percent = metrics.totalAssets > 0 ? entry.value / metrics.totalAssets : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text('${entry.value} thiết bị (${(percent * 100).toStringAsFixed(1)}%)',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                backgroundColor: AppColors.border,
                                color: AppColors.primary,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );

          final typeAllocationList = Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phân loại theo loại thiết bị',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  if (metrics.assetsByType.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Chưa có thông tin phân loại.', style: TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    ...metrics.assetsByType.entries.map((entry) {
                      final percent = metrics.totalAssets > 0 ? entry.value / metrics.totalAssets : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text('${entry.value} thiết bị (${(percent * 100).toStringAsFixed(1)}%)',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                backgroundColor: AppColors.border,
                                color: Colors.blueAccent,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );

          final ticketStatusChart = Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tỷ lệ trạng thái yêu cầu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 35,
                        sectionsSpace: 2,
                        sections: _buildPieSections(metrics.ticketsByStatus),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: const [
                      _Legend(color: AppColors.warning, text: 'Chờ xử lý'),
                      _Legend(color: AppColors.info, text: 'Đang xử lý'),
                      _Legend(color: AppColors.success, text: 'Hoàn thành'),
                    ],
                  ),
                ],
              ),
            ),
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardMetricsProvider);
              await ref.read(dashboardMetricsProvider.future);
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  summaryGrid,
                  const SizedBox(height: 20),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: deptAllocationList),
                        const SizedBox(width: 20),
                        Expanded(child: typeAllocationList),
                        const SizedBox(width: 20),
                        Expanded(child: ticketStatusChart),
                      ],
                    )
                  else ...[
                    deptAllocationList,
                    const SizedBox(height: 16),
                    typeAllocationList,
                    const SizedBox(height: 16),
                    ticketStatusChart,
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingState(message: 'Đang tải báo cáo thống kê...'),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(dashboardMetricsProvider),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> ticketsByStatus) {
    final pending = ticketsByStatus['Chờ xử lý'] ?? 0;
    final inProgress = ticketsByStatus['Đang xử lý'] ?? 0;
    final completed = ticketsByStatus['Hoàn thành'] ?? 0;
    final total = pending + inProgress + completed;

    if (total == 0) {
      return [
        PieChartSectionData(
          color: AppColors.muted,
          value: 1,
          title: '0%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        )
      ];
    }

    return [
      if (pending > 0)
        PieChartSectionData(
          color: AppColors.warning,
          value: pending.toDouble(),
          title: '${(pending / total * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (inProgress > 0)
        PieChartSectionData(
          color: AppColors.info,
          value: inProgress.toDouble(),
          title: '${(inProgress / total * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (completed > 0)
        PieChartSectionData(
          color: AppColors.success,
          value: completed.toDouble(),
          title: '${(completed / total * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
        ),
    ];
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
