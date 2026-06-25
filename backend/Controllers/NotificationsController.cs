using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HoldMaintenance.Api.Data;
using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class NotificationsController : ControllerBase
{
    private readonly AppDbContext _context;

    public NotificationsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("{userId}")]
    public async Task<IActionResult> GetNotifications(string userId)
    {
        var notifications = await _context.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync();
        return Ok(notifications);
    }

    [HttpGet("{userId}/unread-count")]
    public async Task<IActionResult> GetUnreadCount(string userId)
    {
        var count = await _context.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .CountAsync();
        return Ok(count);
    }

    [HttpPost]
    public async Task<IActionResult> CreateNotification([FromBody] Notification notification)
    {
        if (string.IsNullOrEmpty(notification.Id))
        {
            notification.Id = $"notif-{DateTime.UtcNow.Ticks}";
        }
        notification.CreatedAt = DateTime.UtcNow;

        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetNotifications), new { userId = notification.UserId }, notification);
    }

    [HttpPut("{id}/read")]
    public async Task<IActionResult> MarkAsRead(string id)
    {
        var notification = await _context.Notifications.FindAsync(id);
        if (notification == null) return NotFound();

        notification.IsRead = true;
        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpPut("read-all/{userId}")]
    public async Task<IActionResult> MarkAllAsRead(string userId)
    {
        var notifications = await _context.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .ToListAsync();

        foreach (var n in notifications)
        {
            n.IsRead = true;
        }

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteNotification(string id)
    {
        var notification = await _context.Notifications.FindAsync(id);
        if (notification == null) return NotFound();

        _context.Notifications.Remove(notification);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
