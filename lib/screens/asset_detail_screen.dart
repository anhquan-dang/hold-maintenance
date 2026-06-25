import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../presentation/providers/asset_provider.dart';
import '../presentation/providers/support_provider.dart';
import '../presentation/widgets/empty_state.dart';
import '../presentation/widgets/error_state.dart';
import '../presentation/widgets/loading_state.dart';
import '../presentation/widgets/status_badge.dart';
import '../utils/colors.dart';

class AssetDetailScreen extends ConsumerWidget {
  final String assetId;

  const AssetDetailScreen({required this.assetId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetAsync = ref.watch(assetByIdProvider(assetId));
    final ticketsAsync = ref.watch(ticketsByAssetIdProvider(assetId));
    final notesAsync = ref.watch(supportNotesByAssetIdProvider(assetId));
    final assignmentsAsync = ref.watch(assetAssignmentsProvider(assetId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết tài sản')),
      body: assetAsync.when(
        data: (asset) {
          if (asset == null) {
            return const EmptyState(
              title: 'Không tìm thấy tài sản',
              message: 'Tài sản này không tồn tại trong hệ thống.',
              icon: Icons.inventory_2_outlined,
            );
          }

          return ticketsAsync.when(
            data: (tickets) {
              return notesAsync.when(
                data: (notes) {
                  return assignmentsAsync.when(
                    data: (assignments) {
                      final warrantyActive = asset.warrantyExpiry.isAfter(DateTime.now());

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(_assetIcon(asset.assetType), color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              asset.assetCode,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              asset.assetName,
                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _showQrDialog(context, asset.assetCode, asset.assetName),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.border),
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: QrImageView(
                                            data: asset.assetCode,
                                            version: QrVersions.auto,
                                            size: 40.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      StatusBadge(label: asset.statusLabel, color: asset.statusColor),
                                      StatusBadge(
                                        label: warrantyActive ? 'Còn bảo hành' : 'Hết bảo hành',
                                        color: warrantyActive ? 'success' : 'error',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _InfoLine(label: 'Mã tài sản', value: asset.assetCode),
                                  _InfoLine(label: 'Tên tài sản', value: asset.assetName),
                                  _InfoLine(label: 'Loại tài sản', value: asset.assetType),
                                  _InfoLine(label: 'Phòng ban', value: asset.department),
                                  _InfoLine(label: 'Người sử dụng', value: asset.assignedUser),
                                  _InfoLine(label: 'Ngày mua', value: _date(asset.purchaseDate)),
                                  _InfoLine(label: 'Hạn bảo hành', value: _date(asset.warrantyExpiry)),
                                  _InfoLine(label: 'Ghi chú', value: asset.note),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  title: 'Yêu cầu hỗ trợ',
                                  value: tickets.length.toString(),
                                  icon: Icons.confirmation_number_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricCard(
                                  title: 'Lịch sử xử lý',
                                  value: notes.length.toString(),
                                  icon: Icons.history_rounded,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/support/create',
                              arguments: asset.id,
                            ),
                            icon: const Icon(Icons.add_task_rounded),
                            label: const Text('Tạo yêu cầu hỗ trợ'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/assets/add',
                              arguments: asset.id,
                            ),
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Chỉnh sửa tài sản'),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Lịch sử bàn giao & cấp phát',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          if (assignments.isEmpty)
                            const EmptyState(
                              title: 'Chưa có lịch sử bàn giao',
                              message: 'Tài sản này chưa ghi nhận lịch sử bàn giao.',
                              icon: Icons.assignment_turned_in_rounded,
                            )
                          else
                            ...assignments.map(
                              (asg) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: asg.returnedDate == null
                                              ? AppColors.success.withValues(alpha: 0.12)
                                              : AppColors.textSecondary.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          asg.returnedDate == null
                                              ? Icons.person_rounded
                                              : Icons.assignment_return_rounded,
                                          color: asg.returnedDate == null
                                              ? AppColors.success
                                              : AppColors.textSecondary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  asg.userName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  asg.returnedDate == null ? 'Đang sử dụng' : 'Đã hoàn trả',
                                                  style: TextStyle(
                                                    color: asg.returnedDate == null
                                                        ? AppColors.success
                                                        : AppColors.textSecondary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Ngày nhận: ${_date(asg.assignedDate)}${asg.returnedDate != null ? ' - Ngày trả: ${_date(asg.returnedDate!)}' : ''}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            if (asg.note.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                asg.note,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          const Text(
                            'Lịch sử hỗ trợ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          if (notes.isEmpty)
                            const EmptyState(
                              title: 'Chưa có lịch sử hỗ trợ',
                              message: 'Tài sản này chưa phát sinh ghi chú xử lý.',
                              icon: Icons.history_toggle_off_rounded,
                            )
                          else
                            ...notes.map(
                              (note) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.support_agent_rounded),
                                  title: Text(note.content),
                                  subtitle: Text('${note.handledBy} • ${_date(note.createdAt)}'),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const LoadingState(message: 'Đang tải lịch sử bàn giao...'),
                    error: (error, _) => ErrorState(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(assetAssignmentsProvider(assetId)),
                    ),
                  );
                },
                loading: () => const LoadingState(message: 'Đang tải lịch sử hỗ trợ...'),
                error: (error, _) => ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(supportNotesByAssetIdProvider(assetId)),
                ),
              );
            },
            loading: () => const LoadingState(message: 'Đang tải yêu cầu hỗ trợ...'),
            error: (error, _) => ErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(ticketsByAssetIdProvider(assetId)),
            ),
          );
        },
        loading: () => const LoadingState(message: 'Đang tải thông tin tài sản...'),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(assetByIdProvider(assetId)),
        ),
      ),
    );
  }

  void _showQrDialog(BuildContext context, String code, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mã QR Tài sản'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(code, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: QrImageView(
                data: code,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Quét mã này bằng camera thiết bị để truy cập nhanh thông tin tài sản.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  String _date(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  IconData _assetIcon(String type) {
    switch (type) {
      case 'Laptop':
        return Icons.laptop_mac_rounded;
      case 'Máy tính bàn':
        return Icons.desktop_windows_rounded;
      case 'Màn hình':
        return Icons.monitor_rounded;
      case 'Máy in':
        return Icons.print_rounded;
      case 'Điện thoại công ty':
        return Icons.phone_iphone_rounded;
      case 'Thiết bị mạng':
        return Icons.router_rounded;
      case 'License phần mềm':
        return Icons.key_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}
