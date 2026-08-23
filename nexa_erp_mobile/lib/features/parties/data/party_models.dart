enum PartyType {
  customer, vendor, both;

  static PartyType fromBackend(String v) =>
      PartyType.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => PartyType.vendor);
}

class PartyModel {
  final int id;
  final String code;
  final String name;
  final PartyType type;
  final bool isActive;
  final String? phone;
  final String? email;

  PartyModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.isActive,
    this.phone,
    this.email,
  });

  factory PartyModel.fromJson(Map<String, dynamic> j) => PartyModel(
    id: j['id'],
    code: j['code'] ?? '',
    name: j['name'] ?? '',
    type: PartyType.fromBackend(j['type'] ?? 'VENDOR'),
    isActive: j['isActive'] ?? true,
    phone: j['phone'],
    email: j['email'],
  );
}