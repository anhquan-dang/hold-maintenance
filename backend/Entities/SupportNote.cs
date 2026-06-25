namespace HoldMaintenance.Api.Entities;

public class SupportNote
{
    public string Id { get; set; } = string.Empty;
    public string TicketId { get; set; } = string.Empty;
    public string AssetId { get; set; } = string.Empty;
    public string HandledBy { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
