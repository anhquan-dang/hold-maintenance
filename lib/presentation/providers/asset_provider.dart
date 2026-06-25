import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../data/repositories/api_asset_repository.dart';
import '../../domain/models/asset.dart';
import '../../domain/models/asset_assignment.dart';
import '../../domain/repositories/asset_repository.dart';

// Repository provider
final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiAssetRepository(apiClient);
});

// All assets provider
final assetsProvider = FutureProvider<List<Asset>>((ref) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssets();
});

// Asset by ID provider
final assetByIdProvider = FutureProvider.family<Asset?, String>((ref, id) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetById(id);
});

// Asset assignments provider
final assetAssignmentsProvider = FutureProvider.family<List<AssetAssignment>, String>((ref, assetId) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssignmentsByAssetId(assetId);
});

// Assets by status provider
final assetsByStatusProvider = FutureProvider.family<List<Asset>, AssetStatus>((ref, status) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetsByStatus(status);
});

// Assets by department provider
final assetsByDepartmentProvider = FutureProvider.family<List<Asset>, String>((ref, department) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetsByDepartment(department);
});

final assetsByTypeProvider = FutureProvider.family<List<Asset>, String>((ref, assetType) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetsByType(assetType);
});

// Search assets provider
final searchAssetsProvider = FutureProvider.family<List<Asset>, String>((ref, query) async {
  if (query.isEmpty) {
    final assets = await ref.watch(assetsProvider.future);
    return assets;
  }
  final repository = ref.watch(assetRepositoryProvider);
  return repository.searchAssets(query);
});

// Asset write notifier (add / update / delete if needed)
final assetActionProvider = StateNotifierProvider<AssetActionNotifier, bool>((ref) {
  final repository = ref.watch(assetRepositoryProvider);
  return AssetActionNotifier(repository, ref);
});

class AssetActionNotifier extends StateNotifier<bool> {
  final AssetRepository _repository;
  final Ref _ref;

  AssetActionNotifier(this._repository, this._ref) : super(false);

  Future<void> addAsset(Asset asset) async {
    state = true;
    try {
      await _repository.addAsset(asset);
      _ref.invalidate(assetsProvider);
      _ref.invalidate(assetsByDepartmentProvider(asset.department));
    } finally {
      state = false;
    }
  }

  Future<void> updateAsset(Asset asset) async {
    state = true;
    try {
      await _repository.updateAsset(asset);
      _ref.invalidate(assetsProvider);
      _ref.invalidate(assetByIdProvider(asset.id));
      _ref.invalidate(assetsByDepartmentProvider(asset.department));
    } finally {
      state = false;
    }
  }
}
