enum UserRole { departmentManager, technician, maintenanceManager }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatar;
  final String? department;
  final bool isLocked;
  final bool requirePasswordChange;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.department,
    this.isLocked = false,
    this.requirePasswordChange = false,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.departmentManager:
        return 'Quản lý phòng ban';
      case UserRole.technician:
        return 'Nhân viên kỹ thuật';
      case UserRole.maintenanceManager:
        return 'Quản lý kỹ thuật';
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole;
    if (json['role'] is int) {
      parsedRole = UserRole.values[json['role'] as int];
    } else {
      final roleStr = json['role'] as String? ?? '';
      if (roleStr.toLowerCase() == 'maintenancemanager' || roleStr == '2') {
        parsedRole = UserRole.maintenanceManager;
      } else if (roleStr.toLowerCase() == 'technician' || roleStr == '1') {
        parsedRole = UserRole.technician;
      } else {
        parsedRole = UserRole.departmentManager;
      }
    }
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: parsedRole,
      avatar: json['avatar'] as String?,
      department: json['department'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      requirePasswordChange: json['requirePasswordChange'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.index,
      'avatar': avatar,
      'department': department,
      'isLocked': isLocked,
      'requirePasswordChange': requirePasswordChange,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatar,
    String? department,
    bool? isLocked,
    bool? requirePasswordChange,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      department: department ?? this.department,
      isLocked: isLocked ?? this.isLocked,
      requirePasswordChange: requirePasswordChange ?? this.requirePasswordChange,
    );
  }
}
