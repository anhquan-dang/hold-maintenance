namespace HoldMaintenance.Api.Entities;

public enum AssetStatus
{
    InUse = 0,
    InMaintenance = 1,
    Available = 2,
    Retired = 3
}

public class Asset
{
    public string Id { get; set; } = string.Empty;
    public string AssetCode { get; set; } = string.Empty;
    public string AssetName { get; set; } = string.Empty;
    public string AssetType { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public string AssignedUser { get; set; } = string.Empty;
    public DateTime PurchaseDate { get; set; }
    public DateTime WarrantyExpiry { get; set; }
    public AssetStatus Status { get; set; }
    public string Note { get; set; } = string.Empty;
}
