using AutoMapper;
using HoldMaintenance.Api.Data.Repositories;
using HoldMaintenance.Api.DTOs;
using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.Services;

public class DashboardService : IDashboardService
{
    private readonly IAssetRepository _assetRepository;
    private readonly ISupportRepository _supportRepository;
    private readonly IMapper _mapper;

    public DashboardService(IAssetRepository assetRepository, ISupportRepository supportRepository, IMapper mapper)
    {
        _assetRepository = assetRepository;
        _supportRepository = supportRepository;
        _mapper = mapper;
    }

    public async Task<DashboardMetricsDto> GetDashboardMetricsAsync()
    {
        var assets = await _assetRepository.GetAssetsAsync();
        var tickets = await _supportRepository.GetTicketsAsync();
        var now = DateTime.UtcNow;

        var totalAssets = assets.Count;
        var assetsInUse = assets.Count(a => a.Status == AssetStatus.InUse);
        var assetsInMaintenance = assets.Count(a => a.Status == AssetStatus.InMaintenance);
        var openTickets = tickets.Count(t => t.Status != TicketStatus.Completed);
        var completedTickets = tickets.Count(t => t.Status == TicketStatus.Completed);

        // Assets by Department
        var assetsByDept = assets
            .GroupBy(a => a.Department)
            .ToDictionary(g => g.Key, g => g.Count());

        // Tickets by Status
        var ticketsByStatus = tickets
            .GroupBy(t => t.Status.ToString())
            .ToDictionary(
                g => g.Key == "Pending" ? "Chờ xử lý" : g.Key == "InProgress" ? "Đang xử lý" : "Hoàn thành", 
                g => g.Count()
            );
        // Ensure all statuses exist in dict
        if (!ticketsByStatus.ContainsKey("Chờ xử lý")) ticketsByStatus["Chờ xử lý"] = 0;
        if (!ticketsByStatus.ContainsKey("Đang xử lý")) ticketsByStatus["Đang xử lý"] = 0;
        if (!ticketsByStatus.ContainsKey("Hoàn thành")) ticketsByStatus["Hoàn thành"] = 0;

        // Assets by Type
        var assetsByType = assets
            .GroupBy(a => a.AssetType)
            .ToDictionary(g => g.Key, g => g.Count());

        // Expiring Warranty Assets (< 30 days remaining)
        var expiringWarrantyAssets = assets
            .Where(a => {
                var diff = (a.WarrantyExpiry - now).TotalDays;
                return diff >= 0 && diff <= 30;
            })
            .ToList();

        // Top Assets with most support tickets
        var ticketCountsByAsset = tickets
            .GroupBy(t => t.AssetId)
            .Select(g => new { AssetId = g.Key, Count = g.Count() })
            .OrderByDescending(x => x.Count)
            .Take(5)
            .ToList();

        var topTicketsAssets = new List<AssetTicketCountDto>();
        foreach (var item in ticketCountsByAsset)
        {
            var asset = assets.FirstOrDefault(a => a.Id == item.AssetId);
            if (asset != null)
            {
                topTicketsAssets.Add(new AssetTicketCountDto
                {
                    AssetId = asset.Id,
                    AssetCode = asset.AssetCode,
                    AssetName = asset.AssetName,
                    Department = asset.Department,
                    TicketCount = item.Count
                });
            }
        }

        return new DashboardMetricsDto
        {
            TotalAssets = totalAssets,
            AssetsInUse = assetsInUse,
            AssetsInMaintenance = assetsInMaintenance,
            OpenTickets = openTickets,
            CompletedTickets = completedTickets,
            AssetsByDepartment = assetsByDept,
            TicketsByStatus = ticketsByStatus,
            AssetsByType = assetsByType,
            ExpiringWarrantyAssets = _mapper.Map<List<AssetDto>>(expiringWarrantyAssets),
            TopTicketsAssets = topTicketsAssets
        };
    }
}
