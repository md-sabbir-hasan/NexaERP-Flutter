class PermissionModel {
  final int id;
  final String code;
  final String name;
  final String module;

  PermissionModel({required this.id, required this.code, required this.name, required this.module});

  factory PermissionModel.fromJson(Map<String, dynamic> j) => PermissionModel(
    id: j['id'],
    code: j['code'] ?? '',
    name: j['name'] ?? '',
    module: j['module'] ?? '',
  );
}

class RoleModel {
  final int id;
  final String name;
  final String? description;
  final Set<PermissionModel> permissions;
  final int? userCount;

  RoleModel({
    required this.id,
    required this.name,
    this.description,
    required this.permissions,
    this.userCount,
  });

  factory RoleModel.fromJson(Map<String, dynamic> j) => RoleModel(
    id: j['id'],
    name: j['name'] ?? '',
    description: j['description'],
    permissions: (j['permissions'] as List? ?? []).map((e) => PermissionModel.fromJson(e)).toSet(),
    userCount: j['userCount'],
  );
}

class RoleRequest {
  final String name;
  final String? description;
  final Set<int> permissionIds;

  RoleRequest({required this.name, this.description, required this.permissionIds});

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null && description!.isNotEmpty) 'description': description,
    'permissionIds': permissionIds.toList(),
  };
}