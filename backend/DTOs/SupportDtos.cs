namespace HoldMaintenance.Api.DTOs;

public class SupportTicketDto
{
    public string Id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Priority { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string Requester { get; set; } = string.Empty;
    public string? AssignedTo { get; set; }
    public string AssetId { get; set; } = string.Empty;
    public string AssetName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}

public class CreateSupportTicketDto
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Priority { get; set; } = "Medium";
    public string Requester { get; set; } = string.Empty;
    public string AssetId { get; set; } = string.Empty;
    public string AssetName { get; set; } = string.Empty;
}

public class UpdateSupportTicketStatusDto
{
    public string Status { get; set; } = string.Empty;
}

public class AssignSupportTicketDto
{
    public string SupportUser { get; set; } = string.Empty;
}

public class SupportNoteDto
{
    public string Id { get; set; } = string.Empty;
    public string TicketId { get; set; } = string.Empty;
    public string AssetId { get; set; } = string.Empty;
    public string HandledBy { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class CreateSupportNoteDto
{
    public string TicketId { get; set; } = string.Empty;
    public string AssetId { get; set; } = string.Empty;
    public string HandledBy { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
}
