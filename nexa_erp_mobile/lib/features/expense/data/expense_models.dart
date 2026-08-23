enum ExpenseStatus {
  draft, posted, cancelled;

  static ExpenseStatus fromBackend(String v) =>
      ExpenseStatus.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => ExpenseStatus.draft);

  String get label {
    switch (this) {
      case ExpenseStatus.draft: return 'Draft';
      case ExpenseStatus.posted: return 'Posted';
      case ExpenseStatus.cancelled: return 'Cancelled';
    }
  }
}

enum ExpensePaymentStatus {
  unpaid, partial, paid;

  static ExpensePaymentStatus fromBackend(String v) =>
      ExpensePaymentStatus.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => ExpensePaymentStatus.unpaid);

  String get label {
    switch (this) {
      case ExpensePaymentStatus.unpaid: return 'Unpaid';
      case ExpensePaymentStatus.partial: return 'Partial';
      case ExpensePaymentStatus.paid: return 'Paid';
    }
  }
}

class BudgetWarning {
  final String? accountName;
  final double budgetAmount;
  final double actualBeforePosting;
  final double transactionAmount;
  final double projectedActual;
  final double exceededAmount;
  final String? message;

  BudgetWarning({
    this.accountName,
    required this.budgetAmount,
    required this.actualBeforePosting,
    required this.transactionAmount,
    required this.projectedActual,
    required this.exceededAmount,
    this.message,
  });

  factory BudgetWarning.fromJson(Map<String, dynamic> j) => BudgetWarning(
    accountName: j['accountName'],
    budgetAmount: (j['budgetAmount'] ?? 0).toDouble(),
    actualBeforePosting: (j['actualBeforePosting'] ?? 0).toDouble(),
    transactionAmount: (j['transactionAmount'] ?? 0).toDouble(),
    projectedActual: (j['projectedActual'] ?? 0).toDouble(),
    exceededAmount: (j['exceededAmount'] ?? 0).toDouble(),
    message: j['message'],
  );
}

class ExpenseModel {
  final int id;
  final String expenseNumber;
  final DateTime expenseDate;
  final int expenseAccountId;
  final String? expenseAccountName;
  final int? costCenterId;
  final String? costCenterName;
  final bool paidImmediately;
  final int? paymentAccountId;
  final String? paymentAccountName;
  final int? partyId;
  final String? partyName;
  final double amount;
  final double paidAmount;
  final double dueAmount;
  final ExpensePaymentStatus paymentStatus;
  final String? referenceNumber;
  final String? attachmentUrl;
  final String? notes;
  final ExpenseStatus status;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final DateTime? createdAt;
  final List<BudgetWarning> budgetWarnings;

  ExpenseModel({
    required this.id,
    required this.expenseNumber,
    required this.expenseDate,
    required this.expenseAccountId,
    this.expenseAccountName,
    this.costCenterId,
    this.costCenterName,
    required this.paidImmediately,
    this.paymentAccountId,
    this.paymentAccountName,
    this.partyId,
    this.partyName,
    required this.amount,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentStatus,
    this.referenceNumber,
    this.attachmentUrl,
    this.notes,
    required this.status,
    this.cancelledAt,
    this.cancelReason,
    this.createdAt,
    this.budgetWarnings = const [],
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> j) => ExpenseModel(
    id: j['id'],
    expenseNumber: j['expenseNumber'] ?? '',
    expenseDate: DateTime.parse(j['expenseDate']),
    expenseAccountId: j['expenseAccountId'],
    expenseAccountName: j['expenseAccountName'],
    costCenterId: j['costCenterId'],
    costCenterName: j['costCenterName'],
    paidImmediately: j['paidImmediately'] ?? false,
    paymentAccountId: j['paymentAccountId'],
    paymentAccountName: j['paymentAccountName'],
    partyId: j['partyId'],
    partyName: j['partyName'],
    amount: (j['amount'] ?? 0).toDouble(),
    paidAmount: (j['paidAmount'] ?? 0).toDouble(),
    dueAmount: (j['dueAmount'] ?? 0).toDouble(),
    paymentStatus: ExpensePaymentStatus.fromBackend(j['paymentStatus'] ?? 'UNPAID'),
    referenceNumber: j['referenceNumber'],
    attachmentUrl: j['attachmentUrl'],
    notes: j['notes'],
    status: ExpenseStatus.fromBackend(j['status'] ?? 'DRAFT'),
    cancelledAt: j['cancelledAt'] != null ? DateTime.tryParse(j['cancelledAt']) : null,
    cancelReason: j['cancelReason'],
    createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
    budgetWarnings: (j['budgetWarnings'] as List? ?? []).map((e) => BudgetWarning.fromJson(e)).toList(),
  );
}

class ExpenseRequest {
  final DateTime expenseDate;
  final int expenseAccountId;
  final int? costCenterId;
  final bool paidImmediately;
  final int? paymentAccountId;
  final int? partyId;
  final double amount;
  final String? referenceNumber;
  final String? attachmentUrl;
  final String? notes;

  ExpenseRequest({
    required this.expenseDate,
    required this.expenseAccountId,
    this.costCenterId,
    required this.paidImmediately,
    this.paymentAccountId,
    this.partyId,
    required this.amount,
    this.referenceNumber,
    this.attachmentUrl,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'expenseDate': '${expenseDate.year.toString().padLeft(4, '0')}-${expenseDate.month.toString().padLeft(2, '0')}-${expenseDate.day.toString().padLeft(2, '0')}',
    'expenseAccountId': expenseAccountId,
    if (costCenterId != null) 'costCenterId': costCenterId,
    'paidImmediately': paidImmediately,
    if (paymentAccountId != null) 'paymentAccountId': paymentAccountId,
    if (partyId != null) 'partyId': partyId,
    'amount': amount,
    if (referenceNumber != null && referenceNumber!.isNotEmpty) 'referenceNumber': referenceNumber,
    if (attachmentUrl != null && attachmentUrl!.isNotEmpty) 'attachmentUrl': attachmentUrl,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}