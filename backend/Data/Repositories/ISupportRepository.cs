using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.Data.Repositories;

public interface ISupportRepository
{
    Task<List<SupportTicket>> GetTicketsAsync();
    Task<SupportTicket?> GetTicketByIdAsync(string id);
    Task<List<SupportTicket>> GetTicketsByStatusAsync(TicketStatus status);
    Task<List<SupportTicket>> GetTicketsByAssetIdAsync(string assetId);
    Task<List<SupportNote>> GetNotesAsync();
    Task<List<SupportNote>> GetNotesByAssetIdAsync(string assetId);
    Task<List<SupportNote>> GetNotesByTicketIdAsync(string ticketId);
    Task CreateTicketAsync(SupportTicket ticket);
    Task UpdateTicketAsync(SupportTicket ticket);
    Task AddNoteAsync(SupportNote note);
}
