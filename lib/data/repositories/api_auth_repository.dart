import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';

class ApiAuthRepository implements UserRepository {
  final ApiClient _apiClient;

  ApiAuthRepository(this._apiClient);

  @override
  Future<User?> getCurrentUser() async {
    final userJson = await _apiClient.readUserJson();
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (response.data == null) {
        throw Exception('Không có dữ liệu trả về từ server');
      }

      final data = response.data!;
      final token = data['token'] as String? ?? '';
      await _apiClient.saveToken(token);

      // Parse user info
      final parsedRole = _parseRoleString(data['role'] as String? ?? '');
      final user = User(
        id: data['userId'] as String? ?? '',
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        role: parsedRole,
        department: data['department'] as String?,
        isLocked: false,
        requirePasswordChange: data['requirePasswordChange'] as bool? ?? false,
      );

      await _apiClient.saveUserJson(jsonEncode(user.toJson()));
      return user;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi không xác định';
      throw Exception(msg);
    }
  }

  @override
  Future<void> logout() async {
    await _apiClient.deleteToken();
    await _apiClient.deleteUserJson();
  }

  @override
  Future<User?> updateProfile(User user) async {
    // In this app, profile update is done via admin update user
    return updateUser(user);
  }

  @override
  Future<List<User>> getUsers() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/users');
      if (response.data == null) return [];
      return response.data!
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải danh sách người dùng';
      throw Exception(msg);
    }
  }

  @override
  Future<List<User>> getStaffByDepartment(String department) async {
    try {
      // In the backend, we filter using query q on GET /users
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/users',
        queryParameters: {'q': department.trim()},
      );
      if (response.data == null) return [];
      return response.data!
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .where((u) => u.department?.toLowerCase() == department.toLowerCase().trim())
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải nhân viên';
      throw Exception(msg);
    }
  }

  @override
  Future<User> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String department,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/users',
        data: {
          'name': name,
          'email': email.trim(),
          'password': password,
          'role': _roleToString(role),
          'department': department,
        },
      );

      if (response.data == null) {
        throw Exception('Không nhận được dữ liệu phản hồi');
      }

      return User.fromJson(response.data!);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tạo người dùng';
      throw Exception(msg);
    }
  }

  @override
  Future<User> updateUser(User user) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/users/${user.id}',
        data: {
          'name': user.name,
          'role': _roleToString(user.role),
          'department': user.department ?? '',
        },
      );

      if (response.data == null) {
        throw Exception('Không nhận được dữ liệu phản hồi');
      }

      final updatedUser = User.fromJson(response.data!);
      
      // If we updated ourselves, update local secure storage
      final current = await getCurrentUser();
      if (current?.id == user.id) {
        await _apiClient.saveUserJson(jsonEncode(updatedUser.toJson()));
      }
      return updatedUser;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi cập nhật người dùng';
      throw Exception(msg);
    }
  }

  @override
  Future<void> lockUser(String userId) async {
    try {
      await _apiClient.dio.post<void>('/users/$userId/lock');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi khóa tài khoản';
      throw Exception(msg);
    }
  }

  @override
  Future<void> unlockUser(String userId) async {
    try {
      await _apiClient.dio.post<void>('/users/$userId/unlock');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi mở khóa tài khoản';
      throw Exception(msg);
    }
  }

  @override
  Future<void> resetPassword(String userId, String newPassword) async {
    try {
      await _apiClient.dio.post<void>(
        '/users/$userId/reset-password',
        data: {'newPassword': newPassword},
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi đặt lại mật khẩu';
      throw Exception(msg);
    }
  }

  @override
  Future<void> changePassword(String userId, String oldPassword, String newPassword) async {
    try {
      await _apiClient.dio.post<void>(
        '/auth/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
      // After password change, we need to clear the forced flag locally
      final current = await getCurrentUser();
      if (current != null) {
        final updated = current.copyWith(requirePasswordChange: false);
        await _apiClient.saveUserJson(jsonEncode(updated.toJson()));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi đổi mật khẩu';
      throw Exception(msg);
    }
  }

  UserRole _parseRoleString(String roleStr) {
    if (roleStr.toLowerCase() == 'maintenancemanager' || roleStr == '2') {
      return UserRole.maintenanceManager;
    } else if (roleStr.toLowerCase() == 'technician' || roleStr == '1') {
      return UserRole.technician;
    } else {
      return UserRole.departmentManager;
    }
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.maintenanceManager:
        return 'MaintenanceManager';
      case UserRole.technician:
        return 'Technician';
      case UserRole.departmentManager:
        return 'DepartmentManager';
    }
  }
}
