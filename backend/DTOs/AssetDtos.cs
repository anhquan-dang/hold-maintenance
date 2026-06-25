using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.DTOs;

public class AssetDto
{
    public string Id { get; set; } = string.Empty;
    public string AssetCode { get; set; } = string.Empty;
    public string AssetName { get; set; } = string.Empty;
    public string AssetType { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public string AssignedUser { get; set; } = string.Empty;
    public DateTime PurchaseDate { get; set; }
    public DateTime WarrantyExpiry { get; set; }
    public string Status { get; set; } = string.Empty; // string represent for enum
    public string Note { get; set; } = string.Empty;
}

public class CreateAssetDto
{
    public string AssetCode { get; set; } = string.Empty;
    public string AssetName { get; set; } = string.Empty;
    public string AssetType { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public string AssignedUser { get; set; } = string.Empty;
    public DateTime PurchaseDate { get; set; }
    public DateTime WarrantyExpiry { get; set; }
    public string Status { get; set; } = "Available";
    public string Note { get; set; } = string.Empty;
}

public class UpdateAssetDto
{
    public string AssetCode { get; set; } = string.Empty;
    public string AssetName { get; set; } = string.Empty;
    public string AssetType { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public string AssignedUser { get; set; } = string.Empty;
    public DateTime PurchaseDate { get; set; }
    public DateTime WarrantyExpiry { get; set; }
    public string Status { get; set; } = string.Empty;
    public string Note { get; set; } = string.Empty;
}

public class AssetAssignmentDto
{
    public string Id { get; set; } = string.Empty;
    public string AssetId { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public DateTime AssignedDate { get; set; }
    public DateTime? ReturnedDate { get; set; }
    public string Note { get; set; } = string.Empty;
}

public class CreateAssetAssignmentDto
{
    public string UserId { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public DateTime AssignedDate { get; set; }
    public string Note { get; set; } = string.Empty;
}
