import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../domain/models/asset.dart';
import '../presentation/providers/asset_provider.dart';

class AddAssetScreen extends ConsumerStatefulWidget {
  final String? assetId;

  const AddAssetScreen({this.assetId, super.key});

  @override
  ConsumerState<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends ConsumerState<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _assetCodeController = TextEditingController();
  final _assetNameController = TextEditingController();
  final _assignedUserController = TextEditingController();
  final _noteController = TextEditingController();

  String _assetType = 'Laptop';
  String _department = 'Kỹ thuật';
  AssetStatus _status = AssetStatus.inUse;
  DateTime _purchaseDate = DateTime.now();
  DateTime _warrantyExpiry = DateTime.now().add(const Duration(days: 365));
  bool _loadedEditData = false;

  final _assetTypes = const [
    'Laptop',
    'Máy tính bàn',
    'Màn hình',
    'Máy in',
    'Điện thoại công ty',
    'Thiết bị mạng',
    'License phần mềm',
  ];

  final _departments = const [
    'Kỹ thuật',
    'QA',
    'Kinh doanh',
    'Kế toán',
    'Nhân sự',
  ];

  @override
  void dispose() {
    _assetCodeController.dispose();
    _assetNameController.dispose();
    _assignedUserController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.assetId == null
        ? null
        : await ref.read(assetByIdProvider(widget.assetId!).future);

    final asset = Asset(
      id: existing?.id ?? 'asset-${DateTime.now().millisecondsSinceEpoch}',
      assetCode: _assetCodeController.text.trim().toUpperCase(),
      assetName: _assetNameController.text.trim(),
      assetType: _assetType,
      department: _department,
      assignedUser: _assignedUserController.text.trim(),
      purchaseDate: _purchaseDate,
      warrantyExpiry: _warrantyExpiry,
      status: _status,
      note: _noteController.text.trim(),
    );

    final notifier = ref.read(assetActionProvider.notifier);
    if (existing == null) {
      await notifier.addAsset(asset);
    } else {
      await notifier.updateAsset(asset);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(existing == null ? 'Tạo tài sản thành công' : 'Cập nhật tài sản thành công')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(assetActionProvider);
    final editAssetAsync = widget.assetId == null
        ? null
        : ref.watch(assetByIdProvider(widget.assetId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assetId == null ? 'Thêm tài sản' : 'Chỉnh sửa tài sản'),
      ),
      body: editAssetAsync?.when(
            data: (asset) {
              if (asset != null && !_loadedEditData) {
                _loadAsset(asset);
              }
              return _buildForm(isLoading);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
          ) ??
          _buildForm(isLoading),
    );
  }

  void _loadAsset(Asset asset) {
    _assetCodeController.text = asset.assetCode;
    _assetNameController.text = asset.assetName;
    _assignedUserController.text = asset.assignedUser;
    _noteController.text = asset.note;
    _assetType = asset.assetType;
    _department = asset.department;
    _status = asset.status;
    _purchaseDate = asset.purchaseDate;
    _warrantyExpiry = asset.warrantyExpiry;
    _loadedEditData = true;
  }

  Widget _buildForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _textField(
              controller: _assetCodeController,
              label: 'Mã tài sản',
              hint: 'VD: LTENG001',
              icon: Icons.qr_code_rounded,
            ),
            const SizedBox(height: 14),
            _textField(
              controller: _assetNameController,
              label: 'Tên tài sản',
              hint: 'VD: Dell Latitude 5440',
              icon: Icons.inventory_2_rounded,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _assetType,
              decoration: const InputDecoration(
                labelText: 'Loại tài sản',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: _assetTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _assetType = value);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _department,
              decoration: const InputDecoration(
                labelText: 'Phòng ban',
                prefixIcon: Icon(Icons.business_rounded),
              ),
              items: _departments.map((dept) => DropdownMenuItem(value: dept, child: Text(dept))).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _department = value);
              },
            ),
            const SizedBox(height: 14),
            _textField(
              controller: _assignedUserController,
              label: 'Người sử dụng',
              hint: 'VD: Nguyễn Văn A',
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _dateField(
                    context: context,
                    label: 'Ngày mua',
                    value: _purchaseDate,
                    onChanged: (value) => setState(() => _purchaseDate = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateField(
                    context: context,
                    label: 'Hạn bảo hành',
                    value: _warrantyExpiry,
                    onChanged: (value) => setState(() => _warrantyExpiry = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<AssetStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                prefixIcon: Icon(Icons.flag_rounded),
              ),
              items: AssetStatus.values
                  .map((status) => DropdownMenuItem(value: status, child: Text(status.statusLabel)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 14),
            _textField(
              controller: _noteController,
              label: 'Ghi chú',
              hint: 'VD: Máy cấp phát cho nhân sự mới',
              icon: Icons.notes_rounded,
              maxLines: 3,
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
                    : const Icon(Icons.save_rounded),
                label: Text(widget.assetId == null ? 'Lưu tài sản' : 'Cập nhật tài sản'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: DateFormat('dd/MM/yyyy').format(value),
        prefixIcon: const Icon(Icons.calendar_today_rounded),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}
