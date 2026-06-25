import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../data/repositories/api_support_repository.dart';
import '../../domain/models/support_note.dart';
import '../../domain/models/support_ticket.dart';
import '../../domain/repositories/support_repository.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiSupportRepository(apiClient);
});

final supportTicketsProvider = FutureProvider<List<SupportTicket>>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getTickets();
});

final supportTicketByIdProvider = FutureProvider.family<SupportTicket?, String>((ref, ticketId) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getTicketById(ticketId);
});

final ticketsByStatusProvider = FutureProvider.family<List<SupportTicket>, TicketStatus>((ref, status) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getTicketsByStatus(status);
});

final ticketsByAssetIdProvider = FutureProvider.family<List<SupportTicket>, String>((ref, assetId) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getTicketsByAssetId(assetId);
});

final supportNotesProvider = FutureProvider<List<SupportNote>>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getNotes();
});

final supportNotesByAssetIdProvider = FutureProvider.family<List<SupportNote>, String>((ref, assetId) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getNotesByAssetId(assetId);
});

final supportNotesByTicketIdProvider = FutureProvider.family<List<SupportNote>, String>((ref, ticketId) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getNotesByTicketId(ticketId);
});

final supportNotifierProvider = StateNotifierProvider<SupportNotifier, bool>((ref) {
  final repository = ref.watch(supportRepositoryProvider);
  return SupportNotifier(repository, ref);
});

class SupportNotifier extends StateNotifier<bool> {
  final SupportRepository _repository;
  final Ref _ref;

  SupportNotifier(this._repository, this._ref) : super(false);

  Future<void> createTicket(SupportTicket ticket) async {
    state = true;
    try {
      await _repository.createTicket(ticket);
      _invalidateTickets(ticketId: ticket.id, assetId: ticket.assetId);
    } finally {
      state = false;
    }
  }

  Future<void> assignTicket(String ticketId, String supportUser) async {
    state = true;
    try {
      final ticket = await _repository.getTicketById(ticketId);
      await _repository.assignTicket(ticketId, supportUser);
      _invalidateTickets(ticketId: ticketId, assetId: ticket?.assetId);
    } finally {
      state = false;
    }
  }

  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    state = true;
    try {
      final ticket = await _repository.getTicketById(ticketId);
      await _repository.updateTicketStatus(ticketId, status);
      _invalidateTickets(ticketId: ticketId, assetId: ticket?.assetId);
    } finally {
      state = false;
    }
  }

  Future<void> addNote(SupportNote note) async {
    state = true;
    try {
      await _repository.addNote(note);
      _ref.invalidate(supportNotesProvider);
      _ref.invalidate(supportNotesByAssetIdProvider(note.assetId));
      _ref.invalidate(supportNotesByTicketIdProvider(note.ticketId));
    } finally {
      state = false;
    }
  }

  void _invalidateTickets({String? ticketId, String? assetId}) {
    _ref.invalidate(supportTicketsProvider);
    for (final status in TicketStatus.values) {
      _ref.invalidate(ticketsByStatusProvider(status));
    }
    if (ticketId != null) {
      _ref.invalidate(supportTicketByIdProvider(ticketId));
    }
    if (assetId != null && assetId.isNotEmpty) {
      _ref.invalidate(ticketsByAssetIdProvider(assetId));
    }
  }
}

final supportSummaryProvider = FutureProvider<SupportSummary>((ref) async {
  final tickets = await ref.watch(supportTicketsProvider.future);

  return SupportSummary(
    pending: tickets.where((item) => item.status == TicketStatus.pending).length,
    inProgress: tickets.where((item) => item.status == TicketStatus.inProgress).length,
    completed: tickets.where((item) => item.status == TicketStatus.completed).length,
  );
});

class SupportSummary {
  final int pending;
  final int inProgress;
  final int completed;

  const SupportSummary({
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  int get total => pending + inProgress + completed;
}
