using Microsoft.EntityFrameworkCore;
using HoldMaintenance.Api.Entities;

namespace HoldMaintenance.Api.Data.Repositories;

public class SupportRepository : ISupportRepository
{
    private readonly AppDbContext _context;

    public SupportRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<SupportTicket>> GetTicketsAsync()
    {
        return await _context.SupportTickets.OrderByDescending(t => t.CreatedAt).ToListAsync();
    }

    public async Task<SupportTicket?> GetTicketByIdAsync(string id)
    {
        return await _context.SupportTickets.FindAsync(id);
    }

    public async Task<List<SupportTicket>> GetTicketsByStatusAsync(TicketStatus status)
    {
        return await _context.SupportTickets
            .Where(t => t.Status == status)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<SupportTicket>> GetTicketsByAssetIdAsync(string assetId)
    {
        return await _context.SupportTickets
            .Where(t => t.AssetId == assetId)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<SupportNote>> GetNotesAsync()
    {
        return await _context.SupportNotes.OrderByDescending(n => n.CreatedAt).ToListAsync();
    }

    public async Task<List<SupportNote>> GetNotesByAssetIdAsync(string assetId)
    {
        return await _context.SupportNotes
            .Where(n => n.AssetId == assetId)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<SupportNote>> GetNotesByTicketIdAsync(string ticketId)
    {
        return await _context.SupportNotes
            .Where(n => n.TicketId == ticketId)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync();
    }

    public async Task CreateTicketAsync(SupportTicket ticket)
    {
        await _context.SupportTickets.AddAsync(ticket);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateTicketAsync(SupportTicket ticket)
    {
        _context.SupportTickets.Update(ticket);
        await _context.SaveChangesAsync();
    }

    public async Task AddNoteAsync(SupportNote note)
    {
        await _context.SupportNotes.AddAsync(note);
        await _context.SaveChangesAsync();
    }
}
