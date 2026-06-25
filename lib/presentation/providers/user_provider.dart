import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../data/repositories/api_auth_repository.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';

// Repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiAuthRepository(apiClient);
});

// Current user provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getCurrentUser();
});

// All users provider
final usersProvider = FutureProvider<List<User>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsers();
});

// Staff by department provider
final staffByDepartmentProvider = FutureProvider.family<List<User>, String>((
  ref,
  department,
) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getStaffByDepartment(department);
});

// User action notifier for Admin operations
final userActionProvider = StateNotifierProvider<UserActionNotifier, bool>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserActionNotifier(repository, ref);
});

class UserActionNotifier extends StateNotifier<bool> {
  final UserRepository _repository;
  final Ref _ref;

  UserActionNotifier(this._repository, this._ref) : super(false);

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String department,
  }) async {
    state = true;
    try {
      await _repository.createUser(
        name: name,
        email: email,
        password: password,
        role: role,
        department: department,
      );
      _ref.invalidate(usersProvider);
    } finally {
      state = false;
    }
  }

  Future<void> updateUser(User user) async {
    state = true;
    try {
      await _repository.updateUser(user);
      _ref.invalidate(usersProvider);
      if (_ref.read(currentUserProvider).value?.id == user.id) {
        _ref.invalidate(currentUserProvider);
      }
    } finally {
      state = false;
    }
  }

  Future<void> lockUser(String userId) async {
    state = true;
    try {
      await _repository.lockUser(userId);
      _ref.invalidate(usersProvider);
      if (_ref.read(currentUserProvider).value?.id == userId) {
        _ref.invalidate(currentUserProvider);
      }
    } finally {
      state = false;
    }
  }

  Future<void> unlockUser(String userId) async {
    state = true;
    try {
      await _repository.unlockUser(userId);
      _ref.invalidate(usersProvider);
      if (_ref.read(currentUserProvider).value?.id == userId) {
        _ref.invalidate(currentUserProvider);
      }
    } finally {
      state = false;
    }
  }

  Future<void> resetPassword(String userId, String newPassword) async {
    state = true;
    try {
      await _repository.resetPassword(userId, newPassword);
      _ref.invalidate(usersProvider);
    } finally {
      state = false;
    }
  }

  Future<void> changePassword(String userId, String oldPassword, String newPassword) async {
    state = true;
    try {
      await _repository.changePassword(userId, oldPassword, newPassword);
      _ref.invalidate(currentUserProvider);
    } finally {
      state = false;
    }
  }
}
