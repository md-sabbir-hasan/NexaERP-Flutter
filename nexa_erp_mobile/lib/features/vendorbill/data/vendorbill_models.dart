enum VendorBillStatus {
  draft, approved, posted, partial, paid, cancelled;

  static VendorBillStatus fromBackend(String v) =>
      VendorBillStatus.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => VendorBillStatus.draft);

  String get label {
    switch (this) {
      case VendorBillStatus.draft: return 'Draft';
      case VendorBillStatus.approved: return 'Approved';
      case VendorBillStatus.posted: return 'Posted';
      case VendorBillStatus.partial: return 'Partial';
      case VendorBillStatus.paid: return 'Paid';
      case VendorBillStatus.cancelled: return 'Cancelled';
    }
  }
}

enum VendorBillType {
  expense, purchase, service, asset;

  String get backendValue => name.toUpperCase();
  static VendorBillType fromBackend(String v) =>
      VendorBillType.values.firstWhere((e) => e.backendValue == v, orElse: () => VendorBillType.expense);

  String get label {
    switch (this) {
      case VendorBillType.expense: return 'Expense';
      case VendorBillType.purchase: return 'Purchase';
      case VendorBillType.service: return 'Service';
      case VendorBillType.asset: return 'Asset';
    }
  }
}

enum VendorBillCancelledReason {
  vendorRequested, wrongEntry, duplicateEntry;

  String get backendValue {
    switch (this) {
      case VendorBillCancelledReason.vendorRequested: return 'VENDOR_REQUESTED';
      case VendorBillCancelledReason.wrongEntry: return 'WRONG_ENTRY';
      case VendorBillCancelledReason.duplicateEntry: return 'DUPLICATE_ENTRY';
    }
  }

  String get label {
    switch (this) {
      case VendorBillCancelledReason.vendorRequested: return 'Vendor Requested';
      case VendorBillCancelledReason.wrongEntry: return 'Wrong Entry';
      case VendorBillCancelledReason.duplicateEntry: return 'Duplicate Entry';
    }
  }
}

class BudgetWarning {
  final String? accountName;
  final double budgetAmount;
  final double actualBeforePosting;
  final double transactionAmount;
  final double exceededAmount;
  final String? message;

  BudgetWarning({
    this.accountName,
    required this.budgetAmount,
    required this.actualBeforePosting,
    required this.transactionAmount,
    required this.exceededAmount,
    this.message,
  });

  factory BudgetWarning.fromJson(Map<String, dynamic> j) => BudgetWarning(
    accountName: j['accountName'],
    budgetAmount: (j['budgetAmount'] ?? 0).toDouble(),
    actualBeforePosting: (j['actualBeforePosting'] ?? 0).toDouble(),
    transactionAmount: (j['transactionAmount'] ?? 0).toDouble(),
    exceededAmount: (j['exceededAmount'] ?? 0).toDouble(),
    message: j['message'],
  );
}

class VendorBillItem {
  final int? id;
  final int expenseAccountId;
  final String? expenseAccountName;
  final String? expenseAccountCode;
  final int? costCenterId;
  final String description;
  final double quantity;
  final double unitPrice;
  final double discountPercent;
  final double vatRate;
  final double tdsRate;
  final double? discountAmount;
  final double? vatAmount;
  final double? tdsAmount;
  final double? lineTotal;

  VendorBillItem({
    this.id,
    required this.expenseAccountId,
    this.expenseAccountName,
    this.expenseAccountCode,
    this.costCenterId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0,
    this.vatRate = 0,
    this.tdsRate = 0,
    this.discountAmount,
    this.vatAmount,
    this.tdsAmount,
    this.lineTotal,
  });

  factory VendorBillItem.fromJson(Map<String, dynamic> j) => VendorBillItem(
    id: j['id'],
    expenseAccountId: j['expenseAccountId'],
    expenseAccountName: j['expenseAccountName'],
    expenseAccountCode: j['expenseAccountCode'],
    costCenterId: j['costCenterId'],
    description: j['description'] ?? '',
    quantity: (j['quantity'] ?? 0).toDouble(),
    unitPrice: (j['unitPrice'] ?? 0).toDouble(),
    discountPercent: (j['discountPercent'] ?? 0).toDouble(),
    vatRate: (j['vatRate'] ?? 0).toDouble(),
    tdsRate: (j['tdsRate'] ?? 0).toDouble(),
    discountAmount: (j['discountAmount'] ?? 0).toDouble(),
    vatAmount: (j['vatAmount'] ?? 0).toDouble(),
    tdsAmount: (j['tdsAmount'] ?? 0).toDouble(),
    lineTotal: (j['lineTotal'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'expenseAccountId': expenseAccountId,
    if (costCenterId != null) 'costCenterId': costCenterId,
    'description': description,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'discountPercent': discountPercent,
    'vatRate': vatRate,
    'tdsRate': tdsRate,
  };

  double get computedSubTotal => quantity * unitPrice;
  double get computedDiscountAmount => computedSubTotal * (discountPercent / 100);
  double get computedAfterDiscount => computedSubTotal - computedDiscountAmount;
  double get computedVatAmount => computedAfterDiscount * (vatRate / 100);
  double get computedTdsAmount => computedAfterDiscount * (tdsRate / 100);
  double get computedLineTotal => computedAfterDiscount + computedVatAmount - computedTdsAmount;
}

class VendorBillModel {
  final int id;
  final String billNumber;
  final DateTime billDate;
  final DateTime? dueDate;
  final String? vendorBillRef;
  final int partyId;
  final String? partyName;
  final VendorBillType billType;
  final VendorBillStatus status;
  final String? currencyCode;
  final int? paymentTerms;
  final String? notes;
  final double subTotal;
  final double discountAmount;
  final double vatAmount;
  final double tdsAmount;
  final double grandTotal;
  final double netPayable;
  final double paidAmount;
  final double dueAmount;
  final bool approvalFeatureEnabled;
  final List<VendorBillItem> items;
  final List<BudgetWarning> budgetWarnings;

  VendorBillModel({
    required this.id,
    required this.billNumber,
    required this.billDate,
    this.dueDate,
    this.vendorBillRef,
    required this.partyId,
    this.partyName,
    required this.billType,
    required this.status,
    this.currencyCode,
    this.paymentTerms,
    this.notes,
    required this.subTotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.tdsAmount,
    required this.grandTotal,
    required this.netPayable,
    required this.paidAmount,
    required this.dueAmount,
    required this.approvalFeatureEnabled,
    required this.items,
    this.budgetWarnings = const [],
  });

  factory VendorBillModel.fromJson(Map<String, dynamic> j) => VendorBillModel(
    id: j['id'],
    billNumber: j['billNumber'] ?? '',
    billDate: DateTime.parse(j['billDate']),
    dueDate: j['dueDate'] != null ? DateTime.tryParse(j['dueDate']) : null,
    vendorBillRef: j['vendorBillRef'],
    partyId: j['partyId'],
    partyName: j['partyName'],
    billType: VendorBillType.fromBackend(j['billType'] ?? 'EXPENSE'),
    status: VendorBillStatus.fromBackend(j['status'] ?? 'DRAFT'),
    currencyCode: j['currencyCode'],
    paymentTerms: j['paymentTerms'],
    notes: j['notes'],
    subTotal: (j['subTotal'] ?? 0).toDouble(),
    discountAmount: (j['discountAmount'] ?? 0).toDouble(),
    vatAmount: (j['vatAmount'] ?? 0).toDouble(),
    tdsAmount: (j['tdsAmount'] ?? 0).toDouble(),
    grandTotal: (j['grandTotal'] ?? 0).toDouble(),
    netPayable: (j['netPayable'] ?? 0).toDouble(),
    paidAmount: (j['paidAmount'] ?? 0).toDouble(),
    dueAmount: (j['dueAmount'] ?? 0).toDouble(),
    approvalFeatureEnabled: j['approvalFeatureEnabled'] ?? false,
    items: (j['items'] as List? ?? []).map((e) => VendorBillItem.fromJson(e)).toList(),
    budgetWarnings: (j['budgetWarnings'] as List? ?? []).map((e) => BudgetWarning.fromJson(e)).toList(),
  );
}

class VendorBillRequest {
  final int partyId;
  final DateTime billDate;
  final String? vendorBillRef;
  final VendorBillType billType;
  final int? paymentTerms;
  final String? notes;
  final List<VendorBillItem> items;

  VendorBillRequest({
    required this.partyId,
    required this.billDate,
    this.vendorBillRef,
    required this.billType,
    this.paymentTerms,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'partyId': partyId,
    'billDate': '${billDate.year.toString().padLeft(4, '0')}-${billDate.month.toString().padLeft(2, '0')}-${billDate.day.toString().padLeft(2, '0')}',
    if (vendorBillRef != null && vendorBillRef!.isNotEmpty) 'vendorBillRef': vendorBillRef,
    'billType': billType.backendValue,
    if (paymentTerms != null) 'paymentTerms': paymentTerms,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'items': items.map((i) => i.toJson()).toList(),
  };
}