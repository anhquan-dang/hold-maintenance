import '../models/asset.dart';
import '../models/asset_assignment.dart';

abstract class AssetRepository {
  Future<List<Asset>> getAssets();
  Future<Asset?> getAssetById(String id);
  Future<void> addAsset(Asset asset);
  Future<void> updateAsset(Asset asset);
  Future<List<Asset>> searchAssets(String query);
  Future<List<Asset>> getAssetsByDepartment(String department);
  Future<List<Asset>> getAssetsByType(String assetType);
  Future<List<Asset>> getAssetsByStatus(AssetStatus status);
  Future<List<AssetAssignment>> getAssignmentsByAssetId(String assetId);
  Future<void> addAssignment(AssetAssignment assignment);
}
