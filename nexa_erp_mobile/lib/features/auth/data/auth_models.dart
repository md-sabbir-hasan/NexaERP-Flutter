class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int userId;
  final String name;
  final String email;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.userId,
    required this.name,
    required this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class CurrentUser {
  final int id;
  final String name;
  final String email;
  final String status;
  final Set<String> roles;
  final Set<String> permissions;

  CurrentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.roles,
    required this.permissions,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      roles: Set<String>.from(json['roles'] ?? []),
      permissions: Set<String>.from(json['permissions'] ?? []),
    );
  }

  bool hasPermission(String code) => permissions.contains(code);
  bool hasRole(String role) => roles.contains(role);
}