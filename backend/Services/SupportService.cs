using AutoMapper;
using HoldMaintenance.Api.Data.Repositories;
using HoldMaintenance.Api.DTOs;
using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.Services;

public class SupportService : ISupportService
{
    private readonly ISupportRepository _supportRepository;
    private readonly IAssetRepository _assetRepository;
    private readonly IMapper _mapper;

    public SupportService(ISupportRepository supportRepository, IAssetRepository assetRepository, IMapper mapper)
    {
        _supportRepository = supportRepository;
        _assetRepository = assetRepository;
        _mapper = mapper;
    }

    public async Task<List<SupportTicketDto>> GetTicketsAsync()
    {
        var tickets = await _supportRepository.GetTicketsAsync();
        return _mapper.Map<List<SupportTicketDto>>(tickets);
    }

    public async Task<SupportTicketDto?> GetTicketByIdAsync(string id)
    {
        var ticket = await _supportRepository.GetTicketByIdAsync(id);
        if (ticket == null) return null;
        return _mapper.Map<SupportTicketDto>(ticket);
    }

    public async Task<List<SupportTicketDto>> GetTicketsByStatusAsync(string status)
    {
        if (Enum.TryParse<TicketStatus>(status, true, out var ticketStatus))
        {
            var tickets = await _supportRepository.GetTicketsByStatusAsync(ticketStatus);
            return _mapper.Map<List<SupportTicketDto>>(tickets);
        }
        return new List<SupportTicketDto>();
    }

    public async Task<List<SupportTicketDto>> GetTicketsByAssetIdAsync(string assetId)
    {
        var tickets = await _supportRepository.GetTicketsByAssetIdAsync(assetId);
        return _mapper.Map<List<SupportTicketDto>>(tickets);
    }

    public async Task<SupportTicketDto> CreateTicketAsync(CreateSupportTicketDto dto)
    {
        var ticket = _mapper.Map<SupportTicket>(dto);
        ticket.Id = $"t-{DateTime.UtcNow.Ticks}";
        ticket.CreatedAt = DateTime.UtcNow;
        ticket.Status = TicketStatus.Pending;

        await _supportRepository.CreateTicketAsync(ticket);
        return _mapper.Map<SupportTicketDto>(ticket);
    }

    public async Task<bool> AssignTicketAsync(string ticketId, string supportUser)
    {
        var ticket = await _supportRepository.GetTicketByIdAsync(ticketId);
        if (ticket == null) return false;

        ticket.AssignedTo = supportUser;
        ticket.Status = TicketStatus.InProgress;
        await _supportRepository.UpdateTicketAsync(ticket);

        // Update the asset status to InMaintenance
        var asset = await _assetRepository.GetAssetByIdAsync(ticket.AssetId);
        if (asset != null)
        {
            asset.Status = AssetStatus.InMaintenance;
            await _assetRepository.UpdateAssetAsync(asset);
        }

        return true;
    }

    public async Task<bool> UpdateTicketStatusAsync(string ticketId, string status)
    {
        var ticket = await _supportRepository.GetTicketByIdAsync(ticketId);
        if (ticket == null) return false;

        if (Enum.TryParse<TicketStatus>(status, true, out var ticketStatus))
        {
            ticket.Status = ticketStatus;
            if (ticketStatus == TicketStatus.Completed)
            {
                ticket.CompletedAt = DateTime.UtcNow;
            }
            await _supportRepository.UpdateTicketAsync(ticket);
            return true;
        }

        return false;
    }

    public async Task<bool> CompleteTicketAsync(string ticketId, string completedBy)
    {
        var ticket = await _supportRepository.GetTicketByIdAsync(ticketId);
        if (ticket == null) return false;

        ticket.Status = TicketStatus.Completed;
        ticket.CompletedAt = DateTime.UtcNow;
        await _supportRepository.UpdateTicketAsync(ticket);

        // Also add a completed processing note automatically
        var note = new SupportNote
        {
            Id = $"note-{DateTime.UtcNow.Ticks}",
            TicketId = ticket.Id,
            AssetId = ticket.AssetId,
            HandledBy = completedBy,
            Content = "Đã hoàn thành xử lý yêu cầu hỗ trợ.",
            CreatedAt = DateTime.UtcNow
        };
        await _supportRepository.AddNoteAsync(note);

        // Update the asset status back to InUse
        var asset = await _assetRepository.GetAssetByIdAsync(ticket.AssetId);
        if (asset != null)
        {
            asset.Status = AssetStatus.InUse;
            await _assetRepository.UpdateAssetAsync(asset);
        }

        return true;
    }

    public async Task<List<SupportNoteDto>> GetNotesByAssetIdAsync(string assetId)
    {
        var notes = await _supportRepository.GetNotesByAssetIdAsync(assetId);
        return _mapper.Map<List<SupportNoteDto>>(notes);
    }

    public async Task<List<SupportNoteDto>> GetNotesByTicketIdAsync(string ticketId)
    {
        var notes = await _supportRepository.GetNotesByTicketIdAsync(ticketId);
        return _mapper.Map<List<SupportNoteDto>>(notes);
    }

    public async Task<SupportNoteDto> AddNoteAsync(CreateSupportNoteDto dto)
    {
        var note = _mapper.Map<SupportNote>(dto);
        note.Id = $"note-{DateTime.UtcNow.Ticks}";
        note.CreatedAt = DateTime.UtcNow;

        await _supportRepository.AddNoteAsync(note);
        return _mapper.Map<SupportNoteDto>(note);
    }
}
