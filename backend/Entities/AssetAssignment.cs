namespace HoldMaintenance.Api.Entities;

public class AssetAssignment
{
    public string Id { get; set; } = string.Empty;
    public string AssetId { get; set; } = string.Empty;
    public Asset? Asset { get; set; }
    public string UserId { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public DateTime AssignedDate { get; set; }
    public DateTime? ReturnedDate { get; set; }
    public string Note { get; set; } = string.Empty;
}
