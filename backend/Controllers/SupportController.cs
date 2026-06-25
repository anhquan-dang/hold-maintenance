using Microsoft.AspNetCore.Mvc;
using HoldMaintenance.Api.DTOs;
using HoldMaintenance.Api.Services;

namespace HoldMaintenance.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SupportController : ControllerBase
{
    private readonly ISupportService _supportService;

    public SupportController(ISupportService supportService)
    {
        _supportService = supportService;
    }

    [HttpGet("tickets")]
    public async Task<IActionResult> GetTickets([FromQuery] string? status, [FromQuery] string? assetId)
    {
        if (!string.IsNullOrEmpty(status))
        {
            var results = await _supportService.GetTicketsByStatusAsync(status);
            return Ok(results);
        }
        if (!string.IsNullOrEmpty(assetId))
        {
            var results = await _supportService.GetTicketsByAssetIdAsync(assetId);
            return Ok(results);
        }
        var tickets = await _supportService.GetTicketsAsync();
        return Ok(tickets);
    }

    [HttpGet("tickets/{id}")]
    public async Task<IActionResult> GetTicketById(string id)
    {
        var ticket = await _supportService.GetTicketByIdAsync(id);
        if (ticket == null)
        {
            return NotFound(new { Message = "Không tìm thấy yêu cầu hỗ trợ" });
        }
        return Ok(ticket);
    }

    [HttpPost("tickets")]
    public async Task<IActionResult> CreateTicket([FromBody] CreateSupportTicketDto dto)
    {
        var result = await _supportService.CreateTicketAsync(dto);
        return CreatedAtAction(nameof(GetTicketById), new { id = result.Id }, result);
    }

    [HttpPost("tickets/{id}/assign")]
    public async Task<IActionResult> AssignTicket(string id, [FromBody] AssignSupportTicketDto dto)
    {
        var success = await _supportService.AssignTicketAsync(id, dto.SupportUser);
        if (!success)
        {
            return NotFound(new { Message = "Không tìm thấy yêu cầu hỗ trợ để bàn giao" });
        }
        return Ok(new { Message = "Bàn giao yêu cầu hỗ trợ thành công" });
    }

    [HttpPatch("tickets/{id}/status")]
    public async Task<IActionResult> UpdateTicketStatus(string id, [FromBody] UpdateSupportTicketStatusDto dto)
    {
        var success = await _supportService.UpdateTicketStatusAsync(id, dto.Status);
        if (!success)
        {
            return NotFound(new { Message = "Không tìm thấy yêu cầu hỗ trợ hoặc trạng thái không hợp lệ" });
        }
        return Ok(new { Message = "Cập nhật trạng thái thành công" });
    }

    [HttpPost("tickets/{id}/complete")]
    public async Task<IActionResult> CompleteTicket(string id, [FromQuery] string completedBy)
    {
        var success = await _supportService.CompleteTicketAsync(id, completedBy);
        if (!success)
        {
            return NotFound(new { Message = "Không tìm thấy yêu cầu hỗ trợ để hoàn thành" });
        }
        return Ok(new { Message = "Yêu cầu hỗ trợ đã hoàn thành thành công" });
    }

    [HttpGet("assets/{assetId}/notes")]
    public async Task<IActionResult> GetNotesByAsset(string assetId)
    {
        var notes = await _supportService.GetNotesByAssetIdAsync(assetId);
        return Ok(notes);
    }

    [HttpGet("tickets/{ticketId}/notes")]
    public async Task<IActionResult> GetNotesByTicket(string ticketId)
    {
        var notes = await _supportService.GetNotesByTicketIdAsync(ticketId);
        return Ok(notes);
    }

    [HttpPost("notes")]
    public async Task<IActionResult> AddNote([FromBody] CreateSupportNoteDto dto)
    {
        var note = await _supportService.AddNoteAsync(dto);
        return Ok(note);
    }
}
