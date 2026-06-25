using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.Data.Repositories;

public interface IAssetRepository
{
    Task<List<Asset>> GetAssetsAsync();
    Task<Asset?> GetAssetByIdAsync(string id);
    Task AddAssetAsync(Asset asset);
    Task UpdateAssetAsync(Asset asset);
    Task DeleteAssetAsync(Asset asset);
    Task<List<Asset>> SearchAssetsAsync(string query);
    Task<List<Asset>> GetAssetsByDepartmentAsync(string department);
    Task<List<Asset>> GetAssetsByTypeAsync(string assetType);
    Task<List<Asset>> GetAssetsByStatusAsync(AssetStatus status);
    Task<List<AssetAssignment>> GetAssignmentsByAssetIdAsync(string assetId);
    Task AddAssignmentAsync(AssetAssignment assignment);
}
