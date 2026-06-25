using Microsoft.EntityFrameworkCore;
using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.Data.Repositories;

public class AssetRepository : IAssetRepository
{
    private readonly AppDbContext _context;

    public AssetRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<Asset>> GetAssetsAsync()
    {
        return await _context.Assets.OrderBy(a => a.AssetName).ToListAsync();
    }

    public async Task<Asset?> GetAssetByIdAsync(string id)
    {
        return await _context.Assets.FindAsync(id);
    }

    public async Task AddAssetAsync(Asset asset)
    {
        await _context.Assets.AddAsync(asset);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAssetAsync(Asset asset)
    {
        _context.Assets.Update(asset);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAssetAsync(Asset asset)
    {
        _context.Assets.Remove(asset);
        await _context.SaveChangesAsync();
    }

    public async Task<List<Asset>> SearchAssetsAsync(string query)
    {
        var term = query.ToLower().Trim();
        if (string.IsNullOrEmpty(term))
        {
            return await GetAssetsAsync();
        }

        return await _context.Assets
            .Where(a => a.AssetCode.ToLower().Contains(term) ||
                        a.AssetName.ToLower().Contains(term) ||
                        a.AssignedUser.ToLower().Contains(term))
            .ToListAsync();
    }

    public async Task<List<Asset>> GetAssetsByDepartmentAsync(string department)
    {
        return await _context.Assets
            .Where(a => a.Department.ToLower() == department.ToLower())
            .ToListAsync();
    }

    public async Task<List<Asset>> GetAssetsByTypeAsync(string assetType)
    {
        return await _context.Assets
            .Where(a => a.AssetType.ToLower() == assetType.ToLower())
            .ToListAsync();
    }

    public async Task<List<Asset>> GetAssetsByStatusAsync(AssetStatus status)
    {
        return await _context.Assets
            .Where(a => a.Status == status)
            .ToListAsync();
    }

    public async Task<List<AssetAssignment>> GetAssignmentsByAssetIdAsync(string assetId)
    {
        return await _context.AssetAssignments
            .Where(aa => aa.AssetId == assetId)
            .OrderByDescending(aa => aa.AssignedDate)
            .ToListAsync();
    }

    public async Task AddAssignmentAsync(AssetAssignment assignment)
    {
        await _context.AssetAssignments.AddAsync(assignment);
        await _context.SaveChangesAsync();
    }
}
