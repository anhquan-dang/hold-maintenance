import 'asset.dart';

class AssetTicketCount {
  final Asset asset;
  final int ticketCount;

  const AssetTicketCount({required this.asset, required this.ticketCount});
}

class DashboardMetrics {
  final int totalAssets;
  final int assetsInUse;
  final int assetsInMaintenance;
  final int openTickets;
  final int completedTickets;
  final Map<String, int> assetsByDepartment;
  final Map<String, int> ticketsByStatus;
  final Map<String, int> assetsByType;
  final List<Asset> expiringWarrantyAssets;
  final List<AssetTicketCount> topTicketsAssets;

  const DashboardMetrics({
    required this.totalAssets,
    required this.assetsInUse,
    required this.assetsInMaintenance,
    required this.openTickets,
    required this.completedTickets,
    required this.assetsByDepartment,
    required this.ticketsByStatus,
    required this.assetsByType,
    required this.expiringWarrantyAssets,
    required this.topTicketsAssets,
  });
}
