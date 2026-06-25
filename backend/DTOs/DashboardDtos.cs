namespace HoldMaintenance.Api.DTOs;

public class AssetTypeCountDto
{
    public string Type { get; set; } = string.Empty;
    public int Count { get; set; }
}

public class AssetTicketCountDto
{
    public string AssetId { get; set; } = string.Empty;
    public string AssetCode { get; set; } = string.Empty;
    public string AssetName { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public int TicketCount { get; set; }
}

public class DashboardMetricsDto
{
    public int TotalAssets { get; set; }
    public int AssetsInUse { get; set; }
    public int AssetsInMaintenance { get; set; }
    public int OpenTickets { get; set; }
    public int CompletedTickets { get; set; }
    public Dictionary<string, int> AssetsByDepartment { get; set; } = new();
    public Dictionary<string, int> TicketsByStatus { get; set; } = new();
    public Dictionary<string, int> AssetsByType { get; set; } = new();
    public List<AssetDto> ExpiringWarrantyAssets { get; set; } = new();
    public List<AssetTicketCountDto> TopTicketsAssets { get; set; } = new();
}
