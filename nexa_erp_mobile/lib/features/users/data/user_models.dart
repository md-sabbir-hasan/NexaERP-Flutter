enum UserStatus {
  active, inactive, locked, pending;

  static UserStatus fromBackend(String v) =>
      UserStatus.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => UserStatus.pending);

  String get label {
    switch (this) {
      case UserStatus.active: return 'Active';
      case UserStatus.inactive: return 'Inactive';
      case UserStatus.locked: return 'Locked';
      case UserStatus.pending: return 'Pending';
    }
  }
}

class AppUser {
  final int id;
  final String name;
  final String email;
  final UserStatus status;
  final int? failedLoginAttempts;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final Set<String> roles;
  final Set<String> permissions;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.failedLoginAttempts,
    this.lastLoginAt,
    this.createdAt,
    required this.roles,
    required this.permissions,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'],
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    status: UserStatus.fromBackend(j['status'] ?? 'PENDING'),
    failedLoginAttempts: j['failedLoginAttempts'],
    lastLoginAt: j['lastLoginAt'] != null ? DateTime.tryParse(j['lastLoginAt']) : null,
    createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
    roles: Set<String>.from(j['roles'] ?? []),
    permissions: Set<String>.from(j['permissions'] ?? []),
  );
}

class UserRequest {
  final String name;
  final String email;
  final Set<int> roleIds;

  UserRequest({required this.name, required this.email, required this.roleIds});

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'roleIds': roleIds.toList(),
  };
}