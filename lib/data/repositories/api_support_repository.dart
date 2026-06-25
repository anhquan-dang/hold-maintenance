import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../domain/models/support_note.dart';
import '../../domain/models/support_ticket.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/support_repository.dart';

class ApiSupportRepository implements SupportRepository {
  final ApiClient _apiClient;

  ApiSupportRepository(this._apiClient);

  @override
  Future<List<SupportTicket>> getTickets() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/support/tickets');
      if (response.data == null) return [];
      return response.data!
          .map((json) => SupportTicket.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải danh sách yêu cầu hỗ trợ';
      throw Exception(msg);
    }
  }

  @override
  Future<SupportTicket?> getTicketById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/support/tickets/$id');
      if (response.data == null) return null;
      return SupportTicket.fromJson(response.data!);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải chi tiết yêu cầu hỗ trợ';
      throw Exception(msg);
    }
  }

  @override
  Future<List<SupportTicket>> getTicketsByStatus(TicketStatus status) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/support/tickets',
        queryParameters: {'status': _statusToString(status)},
      );
      if (response.data == null) return [];
      return response.data!
          .map((json) => SupportTicket.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải yêu cầu hỗ trợ theo trạng thái';
      throw Exception(msg);
    }
  }

  @override
  Future<List<SupportTicket>> getTicketsByAssetId(String assetId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/support/tickets',
        queryParameters: {'assetId': assetId},
      );
      if (response.data == null) return [];
      return response.data!
          .map((json) => SupportTicket.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải yêu cầu hỗ trợ theo tài sản';
      throw Exception(msg);
    }
  }

  @override
  Future<List<SupportNote>> getNotes() async {
    try {
      final tickets = await getTickets();
      final List<SupportNote> allNotes = [];
      await Future.wait(tickets.map((t) async {
        try {
          final notes = await getNotesByTicketId(t.id);
          allNotes.addAll(notes);
        } catch (_) {}
      }));
      allNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allNotes;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<SupportNote>> getNotesByAssetId(String assetId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/support/assets/$assetId/notes');
      if (response.data == null) return [];
      return response.data!
          .map((json) => SupportNote.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải ghi chú tài sản';
      throw Exception(msg);
    }
  }

  @override
  Future<List<SupportNote>> getNotesByTicketId(String ticketId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/support/tickets/$ticketId/notes');
      if (response.data == null) return [];
      return response.data!
          .map((json) => SupportNote.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải ghi chú yêu cầu hỗ trợ';
      throw Exception(msg);
    }
  }

  @override
  Future<void> createTicket(SupportTicket ticket) async {
    try {
      await _apiClient.dio.post<dynamic>(
        '/support/tickets',
        data: {
          'title': ticket.title,
          'description': ticket.description,
          'priority': _priorityToString(ticket.priority),
          'requester': ticket.requester,
          'assetId': ticket.assetId,
          'assetName': ticket.assetName,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tạo yêu cầu hỗ trợ';
      throw Exception(msg);
    }
  }

  @override
  Future<void> assignTicket(String ticketId, String supportUser) async {
    try {
      await _apiClient.dio.post<dynamic>(
        '/support/tickets/$ticketId/assign',
        data: {'supportUser': supportUser},
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi bàn giao yêu cầu hỗ trợ';
      throw Exception(msg);
    }
  }

  @override
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    try {
      if (status == TicketStatus.completed) {
        final userJson = await _apiClient.readUserJson();
        String completedBy = 'IT Support';
        if (userJson != null) {
          final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
          completedBy = user.name;
        }
        await _apiClient.dio.post<dynamic>(
          '/support/tickets/$ticketId/complete',
          queryParameters: {'completedBy': completedBy},
        );
      } else {
        await _apiClient.dio.patch<dynamic>(
          '/support/tickets/$ticketId/status',
          data: {'status': _statusToString(status)},
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi cập nhật trạng thái';
      throw Exception(msg);
    }
  }

  @override
  Future<void> addNote(SupportNote note) async {
    try {
      await _apiClient.dio.post<dynamic>(
        '/support/notes',
        data: {
          'ticketId': note.ticketId,
          'assetId': note.assetId,
          'handledBy': note.handledBy,
          'content': note.content,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi thêm ghi chú';
      throw Exception(msg);
    }
  }

  String _statusToString(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return 'Pending';
      case TicketStatus.inProgress:
        return 'InProgress';
      case TicketStatus.completed:
        return 'Completed';
    }
  }

  String _priorityToString(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }
}
