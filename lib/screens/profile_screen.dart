import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/widgets/empty_state.dart';
import '../presentation/widgets/error_state.dart';
import '../presentation/widgets/loading_state.dart';
import '../utils/colors.dart';
import '../widgets/saas_layout.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editing = false;
  bool _saving = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _departmentController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return SaasLayout(
      currentIndex: 3,
      title: 'Tài khoản',
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const EmptyState(
              title: 'Chưa có người dùng',
              message: 'Vui lòng đăng nhập lại.',
              icon: Icons.person_off_rounded,
            );
          }

          if (_nameController.text.isEmpty) {
            _nameController.text = user.name;
            _emailController.text = user.email;
            _departmentController.text = user.department ?? '';
          }

          final avatarWidget = CircleAvatar(
            radius: isDesktop ? 48 : 36,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

          final profileCard = Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  avatarWidget,
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.roleLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );

          final settingsForm = Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _field(_nameController, 'Họ và tên', Icons.person_outline_rounded, enabled: _editing),
                  const SizedBox(height: 16),
                  _field(_emailController, 'Email', Icons.email_outlined, enabled: false),
                  const SizedBox(height: 16),
                  _field(_departmentController, 'Phòng ban', Icons.business_outlined, enabled: _editing),
                  const SizedBox(height: 24),
                  if (_editing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving
                                ? null
                                : () {
                                    setState(() {
                                      _editing = false;
                                      _nameController.text = user.name;
                                      _emailController.text = user.email;
                                      _departmentController.text = user.department ?? '';
                                    });
                                  },
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ? null : () => _save(user),
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Lưu'),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _editing = true;
                          });
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Chỉnh sửa thông tin'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showChangePassword,
                        icon: const Icon(Icons.lock_reset_rounded, size: 16),
                        label: const Text('Đổi mật khẩu'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded, size: 16),
                        label: const Text('Đăng xuất'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: profileCard,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: settingsForm,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      profileCard,
                      const SizedBox(height: 16),
                      settingsForm,
                    ],
                  ),
          );
        },
        loading: () => const LoadingState(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: enabled ? AppColors.inputBackground : AppColors.muted,
      ),
    );
  }

  Future<void> _save(User user) async {
    setState(() {
      _saving = true;
    });

    try {
      await ref.read(userRepositoryProvider).updateProfile(
            user.copyWith(
              name: _nameController.text.trim(),
              department: _departmentController.text.trim(),
            ),
          );
      ref.invalidate(currentUserProvider);

      if (!mounted) return;
      setState(() {
        _editing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showChangePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: const Text('Chức năng đổi mật khẩu đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await ref.read(userRepositoryProvider).logout();
    ref.invalidate(currentUserProvider);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
