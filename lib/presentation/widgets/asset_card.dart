import 'package:flutter/material.dart';
import '../../domain/models/asset.dart';
import '../../utils/colors.dart';
import 'status_badge.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;

  const AssetCard({required this.asset, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(_assetIcon(asset.assetType), color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${asset.assetCode} - ${asset.assetName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Người sử dụng: ${asset.assignedUser}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(label: asset.statusLabel, color: asset.statusColor),
            ],
          ),
        ),
      ),
    );
  }

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
