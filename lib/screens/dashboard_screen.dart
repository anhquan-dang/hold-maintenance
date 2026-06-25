import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/dashboard_provider.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/widgets/error_state.dart';
import '../presentation/widgets/loading_state.dart';
import '../presentation/widgets/statistic_card.dart';
import '../utils/colors.dart';
import '../widgets/saas_layout.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    return SaasLayout(
      currentIndex: 0,
      title: 'Trang chủ',
      body: userAsync.when(
        data: (user) {
          return metricsAsync.when(
            data: (metrics) {
              final welcomeCard = Card(
                color: AppColors.primary.withValues(alpha: 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chào mừng trở lại, ${user?.name ?? 'Người dùng'}! 👋',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hệ thống ghi nhận ${metrics.openTickets} yêu cầu đang chờ xử lý và ${metrics.expiringWarrantyAssets.length} thiết bị sắp hết bảo hành.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );

              final kpis = [
                StatisticCard(
                  title: 'Tổng tài sản',
                  value: metrics.totalAssets.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
                StatisticCard(
                  title: 'Đang sử dụng',
                  value: metrics.assetsInUse.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                ),
                StatisticCard(
                  title: 'Đang bảo trì',
                  value: metrics.assetsInMaintenance.toString(),
                  icon: Icons.handyman_outlined,
                  color: AppColors.warning,
                ),
                StatisticCard(
                  title: 'Ticket đang xử lý',
                  value: metrics.openTickets.toString(),
                  icon: Icons.assignment_late_outlined,
                  color: AppColors.orange,
                ),
                StatisticCard(
                  title: 'Ticket hoàn thành',
                  value: metrics.completedTickets.toString(),
                  icon: Icons.task_alt_outlined,
                  color: Colors.teal,
                ),
              ];

              final warrantyAlerts = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sắp hết bảo hành (< 30 ngày)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (metrics.expiringWarrantyAssets.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${metrics.expiringWarrantyAssets.length} thiết bị',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (metrics.expiringWarrantyAssets.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            Icon(Icons.verified_user_outlined, color: AppColors.success, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tất cả tài sản đều đang trong thời hạn bảo hành an toàn.',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: metrics.expiringWarrantyAssets.length,
                      itemBuilder: (context, index) {
                        final asset = metrics.expiringWarrantyAssets[index];
                        final diff = asset.warrantyExpiry.difference(DateTime.now()).inDays;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.errorBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                            ),
                            title: Text(asset.assetName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('${asset.assetCode} • Phòng ${asset.department}', style: const TextStyle(fontSize: 11)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Còn $diff ngày',
                                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/assets/detail', arguments: asset.id);
                            },
                          ),
                        );
                      },
                    ),
                ],
              );

              final assetsByDept = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tài sản theo phòng ban',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _getMaxAssetCount(metrics.assetsByDepartment) * 1.1,
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 2,
                            ),
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 24,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final labels = metrics.assetsByDepartment.keys.toList();
                                    final index = value.toInt();
                                    if (index < 0 || index >= labels.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        labels[index],
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: _buildBarGroups(metrics.assetsByDepartment),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );

              final assetsByType = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tài sản theo loại thiết bị',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ...metrics.assetsByType.entries.map((entry) {
                            final type = entry.key;
                            final count = entry.value;
                            final percent = metrics.totalAssets > 0 ? count / metrics.totalAssets : 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                                      Text('$count thiết bị (${(percent * 100).toStringAsFixed(1)}%)',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: percent,
                                      backgroundColor: AppColors.border,
                                      color: AppColors.primary,
                                      minHeight: 5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              final topTroubledAssets = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tài sản cần hỗ trợ nhiều nhất',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (metrics.topTicketsAssets.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Chưa có yêu cầu hỗ trợ nào phát sinh.',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: metrics.topTicketsAssets.length,
                      itemBuilder: (context, index) {
                        final item = metrics.topTicketsAssets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.assessment_rounded, color: AppColors.primary, size: 16),
                            ),
                            title: Text(item.asset.assetName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('${item.asset.assetCode} • Phòng ${item.asset.department}', style: const TextStyle(fontSize: 11)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item.ticketCount} ticket',
                                style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/assets/detail', arguments: item.asset.id);
                            },
                          ),
                        );
                      },
                    ),
                ],
              );

              final ticketStatusBreakdown = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trạng thái yêu cầu hỗ trợ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
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
                          const SizedBox(height: 12),
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
                  ),
                ],
              );

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(dashboardMetricsProvider);
                  await ref.read(dashboardMetricsProvider.future);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      welcomeCard,
                      const SizedBox(height: 24),
                      // KPI Widgets Row or Grid
                      isDesktop
                          ? Row(
                              children: kpis
                                  .map((kpi) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 12),
                                          child: kpi,
                                        ),
                                      ))
                                  .toList(),
                            )
                          : GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.45,
                              children: kpis.sublist(1).map((kpi) => kpi).toList()
                                ..insert(
                                  0,
                                  StatisticCard(
                                    title: 'Tổng tài sản',
                                    value: metrics.totalAssets.toString(),
                                    icon: Icons.inventory_2_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ),
                      const SizedBox(height: 24),

                      // Desktop: 2 Column Layout, Mobile: Single Column Layout
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  assetsByDept,
                                  const SizedBox(height: 24),
                                  assetsByType,
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  warrantyAlerts,
                                  const SizedBox(height: 24),
                                  ticketStatusBreakdown,
                                  const SizedBox(height: 24),
                                  topTroubledAssets,
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        assetsByDept,
                        const SizedBox(height: 24),
                        assetsByType,
                        const SizedBox(height: 24),
                        warrantyAlerts,
                        const SizedBox(height: 24),
                        ticketStatusBreakdown,
                        const SizedBox(height: 24),
                        topTroubledAssets,
                      ],
                    ],
                  ),
                ),
              );
            },
            loading: () => const LoadingState(message: 'Đang tải dữ liệu dashboard...'),
            error: (error, _) => ErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(dashboardMetricsProvider),
            ),
          );
        },
        loading: () => const LoadingState(message: 'Đang tải thông tin...'),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> breakdown) {
    final statusColors = {
      'Chờ xử lý': AppColors.warning,
      'Đang xử lý': AppColors.info,
      'Hoàn thành': AppColors.success,
    };
    final keys = breakdown.keys.toList();
    return [
      for (var i = 0; i < keys.length; i++)
        if ((breakdown[keys[i]] ?? 0) > 0)
          PieChartSectionData(
            value: (breakdown[keys[i]] ?? 0).toDouble(),
            color: statusColors[keys[i]] ?? Colors.grey,
            title: '${breakdown[keys[i]]}',
            radius: 40,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
    ];
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, int> breakdown) {
    final values = breakdown.values.toList();
    return [
      for (var i = 0; i < values.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: values[i].toDouble(),
              width: 16,
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
    ];
  }

  double _getMaxAssetCount(Map<String, int> breakdown) {
    final values = breakdown.values.toList();
    if (values.isEmpty) return 5;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    return maxVal.toDouble().clamp(5, double.infinity);
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
