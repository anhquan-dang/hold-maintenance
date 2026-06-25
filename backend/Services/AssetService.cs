using AutoMapper;
using HoldMaintenance.Api.Data.Repositories;
using HoldMaintenance.Api.DTOs;
using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.Services;

public class AssetService : IAssetService
{
    private readonly IAssetRepository _assetRepository;
    private readonly IMapper _mapper;

    public AssetService(IAssetRepository assetRepository, IMapper mapper)
    {
        _assetRepository = assetRepository;
        _mapper = mapper;
    }

    public async Task<List<AssetDto>> GetAssetsAsync()
    {
        var assets = await _assetRepository.GetAssetsAsync();
        return _mapper.Map<List<AssetDto>>(assets);
    }

    public async Task<AssetDto?> GetAssetByIdAsync(string id)
    {
        var asset = await _assetRepository.GetAssetByIdAsync(id);
        if (asset == null) return null;
        return _mapper.Map<AssetDto>(asset);
    }

    public async Task<AssetDto> CreateAssetAsync(CreateAssetDto dto)
    {
        var asset = _mapper.Map<Asset>(dto);
        asset.Id = $"asset-{DateTime.UtcNow.Ticks}";
        await _assetRepository.AddAssetAsync(asset);
        return _mapper.Map<AssetDto>(asset);
    }

    public async Task<AssetDto?> UpdateAssetAsync(string id, UpdateAssetDto dto)
    {
        var asset = await _assetRepository.GetAssetByIdAsync(id);
        if (asset == null) return null;

        _mapper.Map(dto, asset);
        await _assetRepository.UpdateAssetAsync(asset);
        return _mapper.Map<AssetDto>(asset);
    }

    public async Task<bool> DeleteAssetAsync(string id)
    {
        var asset = await _assetRepository.GetAssetByIdAsync(id);
        if (asset == null) return false;

        await _assetRepository.DeleteAssetAsync(asset);
        return true;
    }

    public async Task<List<AssetDto>> SearchAssetsAsync(string query)
    {
        var assets = await _assetRepository.SearchAssetsAsync(query);
        return _mapper.Map<List<AssetDto>>(assets);
    }

    public async Task<List<AssetAssignmentDto>> GetAssignmentsByAssetIdAsync(string assetId)
    {
        var assignments = await _assetRepository.GetAssignmentsByAssetIdAsync(assetId);
        return _mapper.Map<List<AssetAssignmentDto>>(assignments);
    }

    public async Task<AssetAssignmentDto> AssignAssetAsync(string assetId, CreateAssetAssignmentDto dto)
    {
        var asset = await _assetRepository.GetAssetByIdAsync(assetId);
        if (asset == null)
        {
            throw new Exception("Asset not found");
        }

        // Close any current active assignment (ReturnedDate == null)
        var activeAssignments = await _assetRepository.GetAssignmentsByAssetIdAsync(assetId);
        var currentActive = activeAssignments.FirstOrDefault(a => a.ReturnedDate == null);
        if (currentActive != null)
        {
            currentActive.ReturnedDate = DateTime.UtcNow;
            await _assetRepository.UpdateAssetAsync(asset); // save DbChanges
        }

        // Create new assignment
        var assignment = _mapper.Map<AssetAssignment>(dto);
        assignment.Id = $"asg-{DateTime.UtcNow.Ticks}";
        assignment.AssetId = assetId;
        assignment.ReturnedDate = null;

        await _assetRepository.AddAssignmentAsync(assignment);

        // Update asset's assigned user & status to inUse
        asset.AssignedUser = dto.UserName;
        asset.Status = AssetStatus.InUse;
        await _assetRepository.UpdateAssetAsync(asset);

        return _mapper.Map<AssetAssignmentDto>(assignment);
    }
}
