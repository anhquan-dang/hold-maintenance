import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/asset.dart';
import '../presentation/providers/asset_provider.dart';
import '../presentation/widgets/asset_card.dart';
import '../presentation/widgets/empty_state.dart';
import '../presentation/widgets/error_state.dart';
import '../presentation/widgets/loading_state.dart';
import '../utils/colors.dart';

import '../presentation/providers/user_provider.dart';

class DepartmentAssetDetailScreen extends ConsumerWidget {
  final String? department;

  const DepartmentAssetDetailScreen({this.department, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final userDept = userAsync.valueOrNull?.department ?? '';
    final dept = (department == null || department!.isEmpty) ? userDept : department!;
    final assetsAsync = ref.watch(assetsByDepartmentProvider(dept));

    return Scaffold(
      appBar: AppBar(title: Text('Phòng $dept')),
      body: assetsAsync.when(
        data: (assets) {
          if (assets.isEmpty) {
            return EmptyState(
              title: 'Chưa có tài sản',
              message: 'Phòng $dept chưa có tài sản được ghi nhận.',
              icon: Icons.inventory_2_outlined,
            );
          }

          final inUse = assets.where((item) => item.status == AssetStatus.inUse).length;
          final inMaintenance = assets.where((item) => item.status == AssetStatus.inMaintenance).length;
          final grouped = _groupByType(assets);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHÒNG ${dept.toUpperCase()}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _Metric(label: 'Tổng tài sản', value: assets.length.toString()),
                          _Metric(label: 'Đang sử dụng', value: inUse.toString()),
                          _Metric(label: 'Bảo trì', value: inMaintenance.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...grouped.entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      '${entry.key} (${entry.value.length})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    children: entry.value
                        .map(
                          (asset) => AssetCard(
                            asset: asset,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/assets/detail',
                                arguments: asset.id,
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingState(message: 'Đang tải tài sản phòng ban...'),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(assetsByDepartmentProvider(dept)),
        ),
      ),
    );
  }

  Map<String, List<Asset>> _groupByType(List<Asset> assets) {
    final result = <String, List<Asset>>{};
    for (final asset in assets) {
      result.putIfAbsent(asset.assetType, () => []).add(asset);
    }
    return result;
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
