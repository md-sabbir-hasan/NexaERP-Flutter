enum AccountType {
  asset, liability, equity, revenue, expense;

  String get backendValue => name.toUpperCase();

  static AccountType fromBackend(String value) {
    return AccountType.values.firstWhere(
          (e) => e.backendValue == value,
      orElse: () => AccountType.asset,
    );
  }

  String get label {
    switch (this) {
      case AccountType.asset: return 'Asset';
      case AccountType.liability: return 'Liability';
      case AccountType.equity: return 'Equity';
      case AccountType.revenue: return 'Revenue';
      case AccountType.expense: return 'Expense';
    }
  }
}

class AccountModel {
  final int id;
  final String code;
  final String name;
  final String? description;
  final AccountType type;
  final bool isActive;
  final bool isDefault;
  final bool isCashEquivalent;
  final int? parentId;
  final String? parentName;
  final double currentBalance;
  final bool hasChildren;
  final List<AccountModel> children;

  AccountModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.type,
    required this.isActive,
    required this.isDefault,
    required this.isCashEquivalent,
    this.parentId,
    this.parentName,
    required this.currentBalance,
    required this.hasChildren,
    this.children = const [],
  });

  factory AccountModel.fromJson(Map<String, dynamic> j) => AccountModel(
    id: j['id'],
    code: j['code'] ?? '',
    name: j['name'] ?? '',
    description: j['description'],
    type: AccountType.fromBackend(j['type'] ?? 'ASSET'),
    isActive: j['isActive'] ?? true,
    isDefault: j['isDefault'] ?? false,
    isCashEquivalent: j['isCashEquivalent'] ?? false,
    parentId: j['parentId'],
    parentName: j['parentName'],
    currentBalance: (j['currentBalance'] ?? 0).toDouble(),
    hasChildren: j['hasChildren'] ?? false,
    children: (j['children'] as List? ?? []).map((e) => AccountModel.fromJson(e)).toList(),
  );
}

class AccountRequest {
  final String code;
  final String name;
  final String? description;
  final AccountType type;
  final int? parentId;
  final bool isCashEquivalent;

  AccountRequest({
    required this.code,
    required this.name,
    this.description,
    required this.type,
    this.parentId,
    this.isCashEquivalent = false,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    if (description != null && description!.isNotEmpty) 'description': description,
    'type': type.backendValue,
    if (parentId != null) 'parentId': parentId,
    'isCashEquivalent': isCashEquivalent,
  };
}