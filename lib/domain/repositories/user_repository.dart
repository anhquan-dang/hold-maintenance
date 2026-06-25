import '../models/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User?> login(String email, String password);
  Future<void> logout();
  Future<User?> updateProfile(User user);
  Future<List<User>> getUsers();
  Future<List<User>> getStaffByDepartment(String department);
  
  // Admin-only User Management methods
  Future<User> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String department,
  });
  Future<User> updateUser(User user);
  Future<void> lockUser(String userId);
  Future<void> unlockUser(String userId);
  Future<void> resetPassword(String userId, String newPassword);
  Future<void> changePassword(String userId, String oldPassword, String newPassword);
}
