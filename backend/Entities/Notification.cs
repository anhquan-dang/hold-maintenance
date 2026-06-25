using System;

namespace HoldMaintenance.Api.Entities;

public enum NotificationType
{
    NewRequest = 0,
    Completed = 1,
    Reminder = 2,
    Assigned = 3
}

public class Notification
{
    public string Id { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public NotificationType Type { get; set; }
    public string? RelatedId { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
}
