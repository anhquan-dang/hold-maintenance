import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../domain/models/asset.dart';
import '../../domain/models/dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';

class ApiDashboardRepository implements DashboardRepository {
  final ApiClient _apiClient;

  ApiDashboardRepository(this._apiClient);

  @override
  Future<DashboardMetrics> getDashboardMetrics() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/dashboard');
      if (response.data == null) {
        throw Exception('Không có dữ liệu trả về từ server');
      }

      final json = response.data!;
      
      // Parse ticketsByStatus safely (map keys might need localized labels)
      final rawTicketsByStatus = Map<String, int>.from(json['ticketsByStatus'] as Map? ?? {});
      final ticketsByStatus = <String, int>{};
      
      // Convert backend keys like "Pending", "InProgress", "Completed" to localized keys if necessary,
      // or map whatever the backend sends.
      rawTicketsByStatus.forEach((key, value) {
        String label = key;
        if (key.toLowerCase() == 'pending') {
          label = 'Chờ xử lý';
        } else if (key.toLowerCase() == 'inprogress') {
          label = 'Đang xử lý';
        } else if (key.toLowerCase() == 'completed') {
          label = 'Hoàn thành';
        }
        ticketsByStatus[label] = value;
      });

      return DashboardMetrics(
        totalAssets: json['totalAssets'] as int? ?? 0,
        assetsInUse: json['assetsInUse'] as int? ?? 0,
        assetsInMaintenance: json['assetsInMaintenance'] as int? ?? 0,
        openTickets: json['openTickets'] as int? ?? 0,
        completedTickets: json['completedTickets'] as int? ?? 0,
        assetsByDepartment: Map<String, int>.from(json['assetsByDepartment'] as Map? ?? {}),
        ticketsByStatus: ticketsByStatus,
        assetsByType: Map<String, int>.from(json['assetsByType'] as Map? ?? {}),
        expiringWarrantyAssets: (json['expiringWarrantyAssets'] as List? ?? [])
            .map((e) => Asset.fromJson(e as Map<String, dynamic>))
            .toList(),
        topTicketsAssets: (json['topTicketsAssets'] as List? ?? [])
            .map((e) {
              final asset = Asset(
                id: e['assetId'] as String? ?? '',
                assetCode: e['assetCode'] as String? ?? '',
                assetName: e['assetName'] as String? ?? '',
                assetType: '',
                department: e['department'] as String? ?? '',
                assignedUser: '',
                purchaseDate: DateTime.now(),
                warrantyExpiry: DateTime.now(),
                status: AssetStatus.available,
                note: '',
              );
              final ticketCount = e['ticketCount'] ?? 0;
              return AssetTicketCount(
                asset: asset,
                ticketCount: ticketCount as int,
              );
            })
            .toList(),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải chỉ số trang chủ';
      throw Exception(msg);
    }
  }
}
