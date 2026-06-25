namespace HoldMaintenance.Api.Entities;

public enum TicketPriority
{
    Low = 0,
    Medium = 1,
    High = 2,
    Urgent = 3
}

public enum TicketStatus
{
    Pending = 0,
    InProgress = 1,
    Completed = 2
}

public class SupportTicket
{
    public string Id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public TicketPriority Priority { get; set; }
    public TicketStatus Status { get; set; }
    public string Requester { get; set; } = string.Empty;
    public string? AssignedTo { get; set; }
    public string AssetId { get; set; } = string.Empty;
    public string AssetName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}
