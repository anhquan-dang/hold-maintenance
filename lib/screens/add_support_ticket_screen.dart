import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/support_ticket.dart';
import '../presentation/providers/asset_provider.dart';
import '../presentation/providers/support_provider.dart';
import '../presentation/providers/user_provider.dart';

class AddSupportTicketScreen extends ConsumerStatefulWidget {
  final String? preSelectedAssetId;

  const AddSupportTicketScreen({this.preSelectedAssetId, super.key});

  @override
  ConsumerState<AddSupportTicketScreen> createState() => _AddSupportTicketScreenState();
}

class _AddSupportTicketScreenState extends ConsumerState<AddSupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedAssetId;
  TicketPriority _priority = TicketPriority.medium;

  @override
  void initState() {
    super.initState();
    _selectedAssetId = widget.preSelectedAssetId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final assets = await ref.read(assetsProvider.future);
    final currentUser = await ref.read(currentUserProvider.future);
    final asset = assets.where((item) => item.id == _selectedAssetId).firstOrNull;

    if (asset == null || currentUser == null) return;

    final ticket = SupportTicket(
      id: 'ticket-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      status: TicketStatus.pending,
      requester: currentUser.name,
      assetId: asset.id,
      assetName: asset.assetName,
      createdAt: DateTime.now(),
    );

    await ref.read(supportNotifierProvider.notifier).createTicket(ticket);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tạo yêu cầu hỗ trợ thành công')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetsProvider);
    final isLoading = ref.watch(supportNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo yêu cầu hỗ trợ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              assetsAsync.when(
                data: (assets) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAssetId,
                    decoration: const InputDecoration(
                      labelText: 'Tài sản liên quan',
                      prefixIcon: Icon(Icons.inventory_2_rounded),
                    ),
                    items: assets
                        .map(
                          (asset) => DropdownMenuItem(
                            value: asset.id,
                            child: Text('${asset.assetCode} - ${asset.assetName}'),
                          ),
                        )
                        .toList(),
                    onChanged: widget.preSelectedAssetId != null
                        ? null
                        : (value) => setState(() => _selectedAssetId = value),
                    validator: (value) => value == null ? 'Vui lòng chọn tài sản' : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Không tải được danh sách tài sản: $error'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'VD: Laptop không kết nối được VPN',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập tiêu đề';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<TicketPriority>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Mức ưu tiên',
                  prefixIcon: Icon(Icons.priority_high_rounded),
                ),
                items: TicketPriority.values
                    .map((priority) => DropdownMenuItem(value: priority, child: Text(priority.priorityLabel)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả vấn đề hoặc nhu cầu hỗ trợ kỹ thuật',
                  prefixIcon: Icon(Icons.description_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập mô tả';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: const Text('Gửi yêu cầu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
