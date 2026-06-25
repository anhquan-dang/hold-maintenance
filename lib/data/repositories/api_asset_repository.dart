import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../domain/models/asset.dart';
import '../../domain/models/asset_assignment.dart';
import '../../domain/repositories/asset_repository.dart';

class ApiAssetRepository implements AssetRepository {
  final ApiClient _apiClient;

  ApiAssetRepository(this._apiClient);

  @override
  Future<List<Asset>> getAssets() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/assets');
      if (response.data == null) return [];
      return response.data!
          .map((json) => Asset.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải danh sách tài sản';
      throw Exception(msg);
    }
  }

  @override
  Future<Asset?> getAssetById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/assets/$id');
      if (response.data == null) return null;
      return Asset.fromJson(response.data!);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải chi tiết tài sản';
      throw Exception(msg);
    }
  }

  @override
  Future<void> addAsset(Asset asset) async {
    try {
      await _apiClient.dio.post<dynamic>(
        '/assets',
        data: {
          'assetCode': asset.assetCode,
          'assetName': asset.assetName,
          'assetType': asset.assetType,
          'department': asset.department,
          'assignedUser': asset.assignedUser,
          'purchaseDate': asset.purchaseDate.toIso8601String(),
          'warrantyExpiry': asset.warrantyExpiry.toIso8601String(),
          'status': _statusToString(asset.status),
          'note': asset.note,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi thêm mới tài sản';
      throw Exception(msg);
    }
  }

  @override
  Future<void> updateAsset(Asset asset) async {
    try {
      await _apiClient.dio.put<dynamic>(
        '/assets/${asset.id}',
        data: {
          'assetCode': asset.assetCode,
          'assetName': asset.assetName,
          'assetType': asset.assetType,
          'department': asset.department,
          'assignedUser': asset.assignedUser,
          'purchaseDate': asset.purchaseDate.toIso8601String(),
          'warrantyExpiry': asset.warrantyExpiry.toIso8601String(),
          'status': _statusToString(asset.status),
          'note': asset.note,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi cập nhật tài sản';
      throw Exception(msg);
    }
  }

  @override
  Future<List<Asset>> searchAssets(String query) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/assets',
        queryParameters: {'q': query.trim()},
      );
      if (response.data == null) return [];
      return response.data!
          .map((json) => Asset.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tìm kiếm tài sản';
      throw Exception(msg);
    }
  }

  @override
  Future<List<Asset>> getAssetsByDepartment(String department) async {
    final list = await getAssets();
    return list
        .where((item) => item.department.toLowerCase().trim() == department.toLowerCase().trim())
        .toList();
  }

  @override
  Future<List<Asset>> getAssetsByType(String assetType) async {
    final list = await getAssets();
    return list
        .where((item) => item.assetType.toLowerCase().trim() == assetType.toLowerCase().trim())
        .toList();
  }

  @override
  Future<List<Asset>> getAssetsByStatus(AssetStatus status) async {
    final list = await getAssets();
    return list.where((item) => item.status == status).toList();
  }

  @override
  Future<List<AssetAssignment>> getAssignmentsByAssetId(String assetId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/assets/$assetId/assignments');
      if (response.data == null) return [];
      return response.data!
          .map((json) => AssetAssignment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải lịch sử bàn giao';
      throw Exception(msg);
    }
  }

  @override
  Future<void> addAssignment(AssetAssignment assignment) async {
    try {
      await _apiClient.dio.post<dynamic>(
        '/assets/${assignment.assetId}/assign',
        data: {
          'userId': assignment.userId,
          'userName': assignment.userName,
          'assignedDate': assignment.assignedDate.toIso8601String(),
          'note': assignment.note,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi bàn giao tài sản';
      throw Exception(msg);
    }
  }

  String _statusToString(AssetStatus status) {
    switch (status) {
      case AssetStatus.available:
        return 'Available';
      case AssetStatus.inUse:
        return 'InUse';
      case AssetStatus.inMaintenance:
        return 'InMaintenance';
      case AssetStatus.retired:
        return 'Retired';
    }
  }
}
