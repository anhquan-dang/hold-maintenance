import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/asset.dart';
import '../presentation/providers/asset_provider.dart';
import '../presentation/widgets/empty_state.dart';
import '../presentation/widgets/error_state.dart';
import '../presentation/widgets/loading_state.dart';
import '../utils/colors.dart';
import '../widgets/saas_layout.dart';

class AssetListScreen extends ConsumerStatefulWidget {
  const AssetListScreen({super.key});

  @override
  ConsumerState<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends ConsumerState<AssetListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedDepartment;
  String? _selectedType;
  AssetStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = _searchQuery.isEmpty
        ? ref.watch(assetsProvider)
        : ref.watch(searchAssetsProvider(_searchQuery));

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final headerActions = [
      if (isDesktop) ...[
        FilledButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/assets/add'),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Thêm tài sản'),
        ),
        const SizedBox(width: 12),
      ],
      IconButton(
        onPressed: () => Navigator.pushNamed(context, '/scan'),
        icon: const Icon(Icons.qr_code_scanner_rounded),
        tooltip: 'Quét mã QR',
      ),
    ];

    return SaasLayout(
      currentIndex: 1,
      title: 'Quản lý tài sản',
      actions: headerActions,
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/assets/add'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm tài sản'),
            ),
      body: Column(
        children: [
          // Search & Filter Panel
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Tìm theo mã tài sản, tên thiết bị, người sử dụng...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                assetsAsync.when(
                  data: (assets) => _FilterBar(
                    assets: assets,
                    selectedDepartment: _selectedDepartment,
                    selectedType: _selectedType,
                    selectedStatus: _selectedStatus,
                    onDepartmentChanged: (value) => setState(() => _selectedDepartment = value),
                    onTypeChanged: (value) => setState(() => _selectedType = value),
                    onStatusChanged: (value) => setState(() => _selectedStatus = value),
                    onClear: () {
                      setState(() {
                        _selectedDepartment = null;
                        _selectedType = null;
                        _selectedStatus = null;
                      });
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Content List
          Expanded(
            child: assetsAsync.when(
              data: (assets) {
                final filtered = _applyFilters(assets);
                final departmentGroups = _groupByDepartment(filtered);

                if (departmentGroups.isEmpty) {
                  return EmptyState(
                    title: 'Không có tài sản',
                    message: 'Không tìm thấy tài sản phù hợp với bộ lọc hiện tại.',
                    icon: Icons.inventory_2_outlined,
                    onRetry: () => ref.invalidate(assetsProvider),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(assetsProvider);
                    await ref.read(assetsProvider.future);
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.all(isDesktop ? 24 : 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 200,
                    ),
                    itemCount: departmentGroups.length,
                    itemBuilder: (context, index) {
                      final entry = departmentGroups.entries.elementAt(index);
                      return _DepartmentCard(
                        department: entry.key,
                        assets: entry.value,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/assets/department',
                            arguments: entry.key,
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingState(message: 'Đang tải thông tin tài sản...'),
              error: (error, _) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(assetsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Asset> _applyFilters(List<Asset> assets) {
    return assets.where((asset) {
      final matchDepartment = _selectedDepartment == null || asset.department == _selectedDepartment;
      final matchType = _selectedType == null || asset.assetType == _selectedType;
      final matchStatus = _selectedStatus == null || asset.status == _selectedStatus;
      return matchDepartment && matchType && matchStatus;
    }).toList();
  }

  Map<String, List<Asset>> _groupByDepartment(List<Asset> assets) {
    final result = <String, List<Asset>>{};
    for (final asset in assets) {
      result.putIfAbsent(asset.department, () => []).add(asset);
    }
    return result;
  }
}

class _DepartmentCard extends StatelessWidget {
  final String department;
  final List<Asset> assets;
  final VoidCallback onTap;

  const _DepartmentCard({
    required this.department,
    required this.assets,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inUse = assets.where((item) => item.status == AssetStatus.inUse).length;
    final inMaintenance = assets.where((item) => item.status == AssetStatus.inMaintenance).length;

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Phòng $department',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetricMini(label: 'Tổng số', value: assets.length.toString(), color: AppColors.textPrimary),
                  _MetricMini(label: 'Đang dùng', value: inUse.toString(), color: AppColors.success),
                  _MetricMini(label: 'Bảo trì', value: inMaintenance.toString(), color: AppColors.warning),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricMini({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<Asset> assets;
  final String? selectedDepartment;
  final String? selectedType;
  final AssetStatus? selectedStatus;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<AssetStatus?> onStatusChanged;
  final VoidCallback onClear;

  const _FilterBar({
    required this.assets,
    required this.selectedDepartment,
    required this.selectedType,
    required this.selectedStatus,
    required this.onDepartmentChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final departments = assets.map((item) => item.department).toSet().toList()..sort();
    final types = assets.map((item) => item.assetType).toSet().toList()..sort();

    final isFiltered = selectedDepartment != null || selectedType != null || selectedStatus != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MenuFilter<String>(
            label: selectedDepartment ?? 'Phòng ban',
            values: departments,
            onSelected: onDepartmentChanged,
          ),
          const SizedBox(width: 8),
          _MenuFilter<String>(
            label: selectedType ?? 'Loại tài sản',
            values: types,
            onSelected: onTypeChanged,
          ),
          const SizedBox(width: 8),
          _MenuFilter<AssetStatus>(
            label: selectedStatus?.statusLabel ?? 'Trạng thái',
            values: AssetStatus.values,
            labelBuilder: (value) => value.statusLabel,
            onSelected: onStatusChanged,
          ),
          if (isFiltered) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('Xóa lọc', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuFilter<T> extends StatelessWidget {
  final String label;
  final List<T> values;
  final String Function(T value)? labelBuilder;
  final ValueChanged<T?> onSelected;

  const _MenuFilter({
    required this.label,
    required this.values,
    required this.onSelected,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return OutlinedButton(
          onPressed: () => controller.isOpen ? controller.close() : controller.open(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: const BorderSide(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () => onSelected(null),
          child: const Text('Tất cả', style: TextStyle(fontSize: 13)),
        ),
        ...values.map(
          (value) => MenuItemButton(
            onPressed: () => onSelected(value),
            child: Text(
              labelBuilder?.call(value) ?? value.toString(),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
