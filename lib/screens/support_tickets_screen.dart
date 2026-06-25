import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/support_note.dart';
import '../domain/models/support_ticket.dart';
import '../domain/models/user.dart';
import '../presentation/providers/support_provider.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/widgets/empty_state.dart';
import '../presentation/widgets/error_state.dart';
import '../presentation/widgets/loading_state.dart';
import '../presentation/widgets/support_ticket_card.dart';
import '../utils/colors.dart';
import '../widgets/saas_layout.dart';

class SupportTicketsScreen extends ConsumerStatefulWidget {
  final bool isMyTasksOnly;
  final bool isRequesterOnly;

  const SupportTicketsScreen({
    this.isMyTasksOnly = false,
    this.isRequesterOnly = false,
    super.key,
  });

  @override
  ConsumerState<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends ConsumerState<SupportTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(supportTicketsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final headerActions = [
      if (isDesktop)
        FilledButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/support/create'),
          icon: const Icon(Icons.add_task_rounded, size: 16),
          label: const Text('Tạo yêu cầu'),
        ),
    ];

    return SaasLayout(
      currentIndex: 2,
      title: 'Yêu cầu hỗ trợ',
      actions: headerActions,
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/support/create'),
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Tạo yêu cầu'),
            ),
      body: Column(
        children: [
          // Search / Filter Row
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tiêu đề, người tạo, tài sản...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear_rounded, size: 18),
                      ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Main content: Kanban on Desktop, Tab view on Mobile
          Expanded(
            child: ticketsAsync.when(
              data: (tickets) {
                List<SupportTicket> filterByStatus(TicketStatus status, User? user) {
                  var list = tickets.where((item) => item.status == status);
                  if (widget.isMyTasksOnly && user != null) {
                    list = list.where((item) => item.assignedTo == user.name);
                  } else if (widget.isRequesterOnly && user != null) {
                    list = list.where((item) => item.requester == user.name);
                  }
                  return list
                      .where(
                        (item) =>
                            item.title.toLowerCase().contains(_searchQuery) ||
                            item.requester.toLowerCase().contains(_searchQuery) ||
                            item.assetName.toLowerCase().contains(_searchQuery),
                      )
                      .toList();
                }

                return userAsync.when(
                  data: (user) {
                    if (isDesktop) {
                      return _buildKanbanBoard(
                        pending: filterByStatus(TicketStatus.pending, user),
                        inProgress: filterByStatus(TicketStatus.inProgress, user),
                        completed: filterByStatus(TicketStatus.completed, user),
                        user: user,
                      );
                    } else {
                      return Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Chờ xử lý'),
                              Tab(text: 'Đang xử lý'),
                              Tab(text: 'Hoàn thành'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _TicketList(
                                  tickets: filterByStatus(TicketStatus.pending, user),
                                  onTap: (ticket) => _showActions(context, ref, ticket, user?.name),
                                ),
                                _TicketList(
                                  tickets: filterByStatus(TicketStatus.inProgress, user),
                                  onTap: (ticket) => _showActions(context, ref, ticket, user?.name),
                                ),
                                _TicketList(
                                  tickets: filterByStatus(TicketStatus.completed, user),
                                  onTap: (ticket) => _showActions(context, ref, ticket, user?.name),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                  loading: () => const LoadingState(),
                  error: (error, _) => ErrorState(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(currentUserProvider),
                  ),
                );
              },
              loading: () => const LoadingState(message: 'Đang tải yêu cầu hỗ trợ...'),
              error: (error, _) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(supportTicketsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanBoard({
    required List<SupportTicket> pending,
    required List<SupportTicket> inProgress,
    required List<SupportTicket> completed,
    required dynamic user,
  }) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _KanbanColumn(
              title: 'Chờ xử lý',
              tickets: pending,
              headerColor: AppColors.warning,
              onTapCard: (ticket) => _showActions(context, ref, ticket, user?.name),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _KanbanColumn(
              title: 'Đang xử lý',
              tickets: inProgress,
              headerColor: AppColors.info,
              onTapCard: (ticket) => _showActions(context, ref, ticket, user?.name),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _KanbanColumn(
              title: 'Hoàn thành',
              tickets: completed,
              headerColor: AppColors.success,
              onTapCard: (ticket) => _showActions(context, ref, ticket, user?.name),
            ),
          ),
        ],
      ),
    );
  }

  void _showActions(
    BuildContext context,
    WidgetRef ref,
    SupportTicket ticket,
    String? currentUserName,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thiết bị: ${ticket.assetName}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border),
                if (ticket.status == TicketStatus.pending)
                  ListTile(
                    leading: const Icon(Icons.assignment_ind_outlined, color: AppColors.primary),
                    title: const Text('Nhận xử lý'),
                    onTap: () async {
                      await ref.read(supportNotifierProvider.notifier).assignTicket(
                            ticket.id,
                            currentUserName ?? 'IT Support',
                          );
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                if (ticket.status == TicketStatus.inProgress) ...[
                  ListTile(
                    leading: const Icon(Icons.note_add_outlined, color: AppColors.primary),
                    title: const Text('Thêm ghi chú xử lý'),
                    onTap: () {
                      Navigator.pop(context);
                      _showNoteDialog(context, ref, ticket, currentUserName);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                    title: const Text('Hoàn thành yêu cầu'),
                    onTap: () async {
                      final handledBy = currentUserName ?? ticket.assignedTo ?? 'IT Support';
                      await ref.read(supportNotifierProvider.notifier).addNote(
                            SupportNote(
                              id: 'note-${DateTime.now().millisecondsSinceEpoch}',
                              ticketId: ticket.id,
                              assetId: ticket.assetId,
                              handledBy: handledBy,
                              content: 'Đã hoàn thành xử lý yêu cầu hỗ trợ.',
                              createdAt: DateTime.now(),
                            ),
                          );
                      await ref.read(supportNotifierProvider.notifier).updateTicketStatus(
                            ticket.id,
                            TicketStatus.completed,
                          );
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary),
                  title: const Text('Xem tài sản liên quan'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/assets/detail', arguments: ticket.assetId);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNoteDialog(
    BuildContext context,
    WidgetRef ref,
    SupportTicket ticket,
    String? currentUserName,
  ) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thêm ghi chú xử lý'),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Nhập nội dung đã xử lý hoặc bước tiếp theo...',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final content = controller.text.trim();
                if (content.isEmpty) return;
                await ref.read(supportNotifierProvider.notifier).addNote(
                      SupportNote(
                        id: 'note-${DateTime.now().millisecondsSinceEpoch}',
                        ticketId: ticket.id,
                        assetId: ticket.assetId,
                        handledBy: currentUserName ?? ticket.assignedTo ?? 'IT Support',
                        content: content,
                        createdAt: DateTime.now(),
                      ),
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final List<SupportTicket> tickets;
  final Color headerColor;
  final ValueChanged<SupportTicket> onTapCard;

  const _KanbanColumn({
    required this.title,
    required this.tickets,
    required this.headerColor,
    required this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: const Border(bottom: BorderSide(color: AppColors.border)),
              color: headerColor.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: headerColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tickets.length.toString(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          // Column Content Cards
          Expanded(
            child: tickets.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded, color: AppColors.textMuted, size: 28),
                          const SizedBox(height: 8),
                          const Text(
                            'Trống',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SupportTicketCard(
                          ticket: ticket,
                          onTap: () => onTapCard(ticket),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TicketList extends StatelessWidget {
  final List<SupportTicket> tickets;
  final ValueChanged<SupportTicket> onTap;

  const _TicketList({required this.tickets, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const EmptyState(
        title: 'Không có yêu cầu',
        message: 'Không có bản ghi nào trong nhóm trạng thái này.',
        icon: Icons.assignment_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SupportTicketCard(
            ticket: ticket,
            onTap: () => onTap(ticket),
          ),
        );
      },
    );
  }
}
