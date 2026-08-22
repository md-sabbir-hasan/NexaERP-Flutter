enum JournalEntryType {
  general, sales, purchase, cash, bank, payroll, asset;

  String get backendValue => name.toUpperCase();
  static JournalEntryType fromBackend(String v) =>
      JournalEntryType.values.firstWhere((e) => e.backendValue == v, orElse: () => JournalEntryType.general);

  String get label {
    switch (this) {
      case JournalEntryType.general: return 'General';
      case JournalEntryType.sales: return 'Sales';
      case JournalEntryType.purchase: return 'Purchase';
      case JournalEntryType.cash: return 'Cash';
      case JournalEntryType.bank: return 'Bank';
      case JournalEntryType.payroll: return 'Payroll';
      case JournalEntryType.asset: return 'Asset';
    }
  }
}

enum JournalStatus {
  draft, posted, reversed;

  static JournalStatus fromBackend(String v) =>
      JournalStatus.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => JournalStatus.draft);

  String get label {
    switch (this) {
      case JournalStatus.draft: return 'Draft';
      case JournalStatus.posted: return 'Posted';
      case JournalStatus.reversed: return 'Reversed';
    }
  }
}

enum ApprovalStatusType {
  pending, approved, rejected, returned, none;

  static ApprovalStatusType fromBackend(String? v) {
    if (v == null) return ApprovalStatusType.none;
    return ApprovalStatusType.values.firstWhere(
          (e) => e.name.toUpperCase() == v,
      orElse: () => ApprovalStatusType.none,
    );
  }
}

class JournalLine {
  final int? id;
  final int accountId;
  final String? accountName;
  final String? accountCode;
  final int? costCenterId;
  final String? costCenterName;
  final double debit;
  final double credit;
  final String? description;

  JournalLine({
    this.id,
    required this.accountId,
    this.accountName,
    this.accountCode,
    this.costCenterId,
    this.costCenterName,
    this.debit = 0,
    this.credit = 0,
    this.description,
  });

  factory JournalLine.fromJson(Map<String, dynamic> j) => JournalLine(
    id: j['id'],
    accountId: j['accountId'],
    accountName: j['accountName'],
    accountCode: j['accountCode'],
    costCenterId: j['costCenterId'],
    costCenterName: j['costCenterName'],
    debit: (j['debit'] ?? 0).toDouble(),
    credit: (j['credit'] ?? 0).toDouble(),
    description: j['description'],
  );

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    if (costCenterId != null) 'costCenterId': costCenterId,
    'debit': debit,
    'credit': credit,
    if (description != null && description!.isNotEmpty) 'description': description,
  };

  JournalLine copyWith({
    int? accountId,
    String? accountName,
    String? accountCode,
    double? debit,
    double? credit,
    String? description,
  }) =>
      JournalLine(
        id: id,
        accountId: accountId ?? this.accountId,
        accountName: accountName ?? this.accountName,
        accountCode: accountCode ?? this.accountCode,
        costCenterId: costCenterId,
        costCenterName: costCenterName,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
        description: description ?? this.description,
      );
}

class JournalEntry {
  final int id;
  final String entryNumber;
  final DateTime date;
  final String? description;
  final JournalEntryType type;
  final JournalStatus status;
  final String? sourceType;
  final double totalAmount;
  final List<JournalLine> lines;
  final int? createdBy;
  final bool approvalEnabled;
  final int? approvalRequestId;
  final ApprovalStatusType approvalStatus;

  JournalEntry({
    required this.id,
    required this.entryNumber,
    required this.date,
    this.description,
    required this.type,
    required this.status,
    this.sourceType,
    required this.totalAmount,
    required this.lines,
    this.createdBy,
    required this.approvalEnabled,
    this.approvalRequestId,
    required this.approvalStatus,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
    id: j['id'],
    entryNumber: j['entryNumber'] ?? '',
    date: DateTime.parse(j['date']),
    description: j['description'],
    type: JournalEntryType.fromBackend(j['type'] ?? 'GENERAL'),
    status: JournalStatus.fromBackend(j['status'] ?? 'DRAFT'),
    sourceType: j['sourceType'],
    totalAmount: (j['totalAmount'] ?? 0).toDouble(),
    lines: (j['lines'] as List? ?? []).map((e) => JournalLine.fromJson(e)).toList(),
    createdBy: j['createdBy'],
    approvalEnabled: j['approvalEnabled'] ?? false,
    approvalRequestId: j['approvalRequestId'],
    approvalStatus: ApprovalStatusType.fromBackend(j['approvalStatus']),
  );
}

class JournalEntryRequest {
  final DateTime date;
  final String? description;
  final JournalEntryType type;
  final List<JournalLine> lines;

  JournalEntryRequest({required this.date, this.description, required this.type, required this.lines});

  Map<String, dynamic> toJson() => {
    'date': '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    if (description != null && description!.isNotEmpty) 'description': description,
    'type': type.backendValue,
    'lines': lines.map((l) => l.toJson()).toList(),
  };
}