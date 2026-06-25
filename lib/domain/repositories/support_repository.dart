import '../models/support_note.dart';
import '../models/support_ticket.dart';

abstract class SupportRepository {
  Future<List<SupportTicket>> getTickets();
  Future<SupportTicket?> getTicketById(String id);
  Future<List<SupportTicket>> getTicketsByStatus(TicketStatus status);
  Future<List<SupportTicket>> getTicketsByAssetId(String assetId);
  Future<List<SupportNote>> getNotes();
  Future<List<SupportNote>> getNotesByAssetId(String assetId);
  Future<List<SupportNote>> getNotesByTicketId(String ticketId);
  Future<void> createTicket(SupportTicket ticket);
  Future<void> assignTicket(String ticketId, String supportUser);
  Future<void> updateTicketStatus(String ticketId, TicketStatus status);
  Future<void> addNote(SupportNote note);
}
