enum PaymentType {
  receipt, payment;

  String get backendValue => name.toUpperCase();
  static PaymentType fromBackend(String v) =>
      PaymentType.values.firstWhere((e) => e.backendValue == v, orElse: () => PaymentType.receipt);

  String get label => this == PaymentType.receipt ? 'Receive Payment' : 'Make Payment';
}

enum PaymentStatus {
  draft, posted, cancelled;

  static PaymentStatus fromBackend(String v) =>
      PaymentStatus.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => PaymentStatus.draft);

  String get label {
    switch (this) {
      case PaymentStatus.draft: return 'Draft';
      case PaymentStatus.posted: return 'Posted';
      case PaymentStatus.cancelled: return 'Cancelled';
    }
  }
}

enum PaymentMethod {
  cash, bankTransfer, cheque, bkash, nagad, rocket, card;

  String get backendValue {
    switch (this) {
      case PaymentMethod.cash: return 'CASH';
      case PaymentMethod.bankTransfer: return 'BANK_TRANSFER';
      case PaymentMethod.cheque: return 'CHEQUE';
      case PaymentMethod.bkash: return 'BKASH';
      case PaymentMethod.nagad: return 'NAGAD';
      case PaymentMethod.rocket: return 'ROCKET';
      case PaymentMethod.card: return 'CARD';
    }
  }

  static PaymentMethod fromBackend(String v) =>
      PaymentMethod.values.firstWhere((e) => e.backendValue == v, orElse: () => PaymentMethod.cash);

  String get label {
    switch (this) {
      case PaymentMethod.cash: return 'Cash';
      case PaymentMethod.bankTransfer: return 'Bank Transfer';
      case PaymentMethod.cheque: return 'Cheque';
      case PaymentMethod.bkash: return 'bKash';
      case PaymentMethod.nagad: return 'Nagad';
      case PaymentMethod.rocket: return 'Rocket';
      case PaymentMethod.card: return 'Card';
    }
  }
}

enum PaymentReferenceType {
  invoice, vendorBill, expense;

  String get backendValue {
    switch (this) {
      case PaymentReferenceType.invoice: return 'INVOICE';
      case PaymentReferenceType.vendorBill: return 'VENDOR_BILL';
      case PaymentReferenceType.expense: return 'EXPENSE';
    }
  }
}

class PaymentAllocationRequest {
  final PaymentReferenceType referenceType;
  final int referenceId;
  final double allocatedAmount;

  PaymentAllocationRequest({required this.referenceType, required this.referenceId, required this.allocatedAmount});

  Map<String, dynamic> toJson() => {
    'referenceType': referenceType.backendValue,
    'referenceId': referenceId,
    'allocatedAmount': allocatedAmount,
  };
}

class PaymentAllocation {
  final int id;
  final String referenceType;
  final int referenceId;
  final double allocatedAmount;

  PaymentAllocation({required this.id, required this.referenceType, required this.referenceId, required this.allocatedAmount});

  factory PaymentAllocation.fromJson(Map<String, dynamic> j) => PaymentAllocation(
    id: j['id'],
    referenceType: j['referenceType'] ?? '',
    referenceId: j['referenceId'],
    allocatedAmount: (j['allocatedAmount'] ?? 0).toDouble(),
  );
}

class PaymentModel {
  final int id;
  final String paymentNumber;
  final DateTime paymentDate;
  final PaymentType paymentType;
  final int partyId;
  final String? partyName;
  final int accountId;
  final String? accountName;
  final double amount;
  final double allocatedAmount;
  final double unallocatedAmount;
  final String? currencyCode;
  final PaymentMethod paymentMethod;
  final String? transactionRef;
  final String? notes;
  final PaymentStatus status;
  final bool approvalFeatureEnabled;
  final List<PaymentAllocation> allocations;

  PaymentModel({
    required this.id,
    required this.paymentNumber,
    required this.paymentDate,
    required this.paymentType,
    required this.partyId,
    this.partyName,
    required this.accountId,
    this.accountName,
    required this.amount,
    required this.allocatedAmount,
    required this.unallocatedAmount,
    this.currencyCode,
    required this.paymentMethod,
    this.transactionRef,
    this.notes,
    required this.status,
    required this.approvalFeatureEnabled,
    this.allocations = const [],
  });

  factory PaymentModel.fromJson(Map<String, dynamic> j) => PaymentModel(
    id: j['id'],
    paymentNumber: j['paymentNumber'] ?? '',
    paymentDate: DateTime.parse(j['paymentDate']),
    paymentType: PaymentType.fromBackend(j['paymentType'] ?? 'RECEIPT'),
    partyId: j['partyId'],
    partyName: j['partyName'],
    accountId: j['accountId'],
    accountName: j['accountName'],
    amount: (j['amount'] ?? 0).toDouble(),
    allocatedAmount: (j['allocatedAmount'] ?? 0).toDouble(),
    unallocatedAmount: (j['unallocatedAmount'] ?? 0).toDouble(),
    currencyCode: j['currencyCode'],
    paymentMethod: PaymentMethod.fromBackend(j['paymentMethod'] ?? 'CASH'),
    transactionRef: j['transactionRef'],
    notes: j['notes'],
    status: PaymentStatus.fromBackend(j['status'] ?? 'DRAFT'),
    approvalFeatureEnabled: j['approvalFeatureEnabled'] ?? false,
    allocations: (j['allocations'] as List? ?? []).map((e) => PaymentAllocation.fromJson(e)).toList(),
  );
}

class PaymentRequest {
  final int partyId;
  final int accountId;
  final DateTime paymentDate;
  final PaymentType paymentType;
  final double amount;
  final String? currencyCode;
  final PaymentMethod paymentMethod;
  final String? transactionRef;
  final String? notes;
  final bool autoAllocate;
  final List<PaymentAllocationRequest>? allocations;

  PaymentRequest({
    required this.partyId,
    required this.accountId,
    required this.paymentDate,
    required this.paymentType,
    required this.amount,
    this.currencyCode,
    required this.paymentMethod,
    this.transactionRef,
    this.notes,
    required this.autoAllocate,
    this.allocations,
  });

  Map<String, dynamic> toJson() => {
    'partyId': partyId,
    'accountId': accountId,
    'paymentDate': '${paymentDate.year.toString().padLeft(4, '0')}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}',
    'paymentType': paymentType.backendValue,
    'amount': amount,
    if (currencyCode != null && currencyCode!.isNotEmpty) 'currencyCode': currencyCode,
    'paymentMethod': paymentMethod.backendValue,
    if (transactionRef != null && transactionRef!.isNotEmpty) 'transactionRef': transactionRef,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'autoAllocate': autoAllocate,
    if (!autoAllocate && allocations != null) 'allocations': allocations!.map((a) => a.toJson()).toList(),
  };
}

// Manual allocation
class OutstandingDocument {
  final int id;
  final String documentNumber;
  final double dueAmount;
  final PaymentReferenceType referenceType;

  OutstandingDocument({
    required this.id,
    required this.documentNumber,
    required this.dueAmount,
    required this.referenceType,
  });
}