import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/widgets/empty_state.dart';
import '../presentation/widgets/error_state.dart';
import '../presentation/widgets/loading_state.dart';
import '../utils/colors.dart';
import '../widgets/saas_layout.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final headerActions = [
      FilledButton.icon(
        onPressed: () => _showAddUserDialog(context),
        icon: const Icon(Icons.person_add_rounded, size: 16),
        label: const Text('Thêm thành viên'),
      ),
    ];

    return SaasLayout(
      currentIndex: 4, // Quản lý người dùng index
      title: 'Quản lý người dùng',
      actions: headerActions,
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddUserDialog(context),
              child: const Icon(Icons.person_add_rounded),
            ),
      body: Column(
        children: [
          // Search box
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, email, phòng ban...',
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

          // Users list
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filteredUsers = users.where((u) {
                  return u.name.toLowerCase().contains(_searchQuery) ||
                      u.email.toLowerCase().contains(_searchQuery) ||
                      (u.department?.toLowerCase() ?? '').contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return EmptyState(
                    title: 'Không tìm thấy người dùng',
                    message: _searchQuery.isEmpty
                        ? 'Hệ thống chưa có tài khoản người dùng nào.'
                        : 'Không tìm thấy kết quả phù hợp với từ khóa.',
                    icon: Icons.people_outline_rounded,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(usersProvider);
                    await ref.read(usersProvider.future);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _UserCard(user: user);
                    },
                  ),
                );
              },
              loading: () => const LoadingState(message: 'Đang tải danh sách người dùng...'),
              error: (err, _) => ErrorState(
                message: err.toString(),
                onRetry: () => ref.invalidate(usersProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const _AddUserDialog(),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final User user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = user.isLocked ? AppColors.error : AppColors.success;
    final statusText = user.isLocked ? 'Đã khóa' : 'Đang hoạt động';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      if (user.requirePasswordChange) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                          ),
                          child: const Text(
                            'Yêu cầu đổi MK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Badge(label: user.roleLabel, icon: Icons.shield_outlined),
                      if (user.department != null && user.department!.isNotEmpty)
                        _Badge(label: 'Phòng ${user.department}', icon: Icons.business_outlined),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    showDialog<void>(context: context, builder: (_) => _EditUserDialog(user: user));
                    break;
                  case 'lock':
                    _toggleLockState(context, ref);
                    break;
                  case 'reset':
                    showDialog<void>(context: context, builder: (_) => _ResetPasswordDialog(user: user));
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                      SizedBox(width: 8),
                      Text('Sửa thông tin', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'lock',
                  child: Row(
                    children: [
                      Icon(
                        user.isLocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                        size: 16,
                        color: user.isLocked ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.lock_reset_rounded, size: 16, color: AppColors.warning),
                      SizedBox(width: 8),
                      Text('Đặt lại mật khẩu', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLockState(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(userActionProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (user.isLocked) {
        await notifier.unlockUser(user.id);
        messenger.showSnackBar(const SnackBar(content: Text('Đã mở khóa tài khoản thành công.')));
      } else {
        await notifier.lockUser(user.id);
        messenger.showSnackBar(const SnackBar(content: Text('Đã khóa tài khoản thành công.')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Không thể thực hiện tác vụ: $e')));
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Badge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _AddUserDialog extends ConsumerStatefulWidget {
  const _AddUserDialog();

  @override
  ConsumerState<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deptController = TextEditingController();
  UserRole _role = UserRole.departmentManager;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm thành viên mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu ban đầu'),
                  validator: (val) => val == null || val.length < 6 ? 'Mật khẩu phải từ 6 ký tự trở lên' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: _role,
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                  items: const [
                    DropdownMenuItem(value: UserRole.departmentManager, child: Text('Quản lý phòng ban')),
                    DropdownMenuItem(value: UserRole.technician, child: Text('Nhân viên kỹ thuật')),
                    DropdownMenuItem(value: UserRole.maintenanceManager, child: Text('Quản lý kỹ thuật (Admin)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _role = val);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _deptController,
                  decoration: const InputDecoration(labelText: 'Phòng ban (ví dụ: IT, HR, Sales...)'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập phòng ban' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Tạo'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(userActionProvider.notifier).createUser(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _role,
            department: _deptController.text.trim(),
          );
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Thêm người dùng thành công.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _EditUserDialog extends ConsumerStatefulWidget {
  final User user;

  const _EditUserDialog({required this.user});

  @override
  ConsumerState<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends ConsumerState<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _deptController;
  late UserRole _role;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _deptController = TextEditingController(text: widget.user.department ?? '');
    _role = widget.user.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa thông tin'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Vai trò'),
                items: const [
                  DropdownMenuItem(value: UserRole.departmentManager, child: Text('Quản lý phòng ban')),
                  DropdownMenuItem(value: UserRole.technician, child: Text('Nhân viên kỹ thuật')),
                  DropdownMenuItem(value: UserRole.maintenanceManager, child: Text('Quản lý kỹ thuật (Admin)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _role = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deptController,
                decoration: const InputDecoration(labelText: 'Phòng ban'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập phòng ban' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Lưu'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = widget.user.copyWith(
        name: _nameController.text.trim(),
        role: _role,
        department: _deptController.text.trim(),
      );
      await ref.read(userActionProvider.notifier).updateUser(updated);
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Cập nhật người dùng thành công.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _ResetPasswordDialog extends ConsumerStatefulWidget {
  final User user;

  const _ResetPasswordDialog({required this.user});

  @override
  ConsumerState<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<_ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Đặt lại mật khẩu cho ${widget.user.name}'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Đặt mật khẩu mới cho người dùng. Người dùng sẽ bắt buộc phải thay đổi mật khẩu này ở lần đăng nhập tiếp theo.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                validator: (val) => val == null || val.length < 6 ? 'Mật khẩu mới phải từ 6 ký tự trở lên' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Xác nhận'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(userActionProvider.notifier).resetPassword(
            widget.user.id,
            _passwordController.text,
          );
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Đặt lại mật khẩu thành công.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
