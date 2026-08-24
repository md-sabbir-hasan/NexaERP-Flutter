enum InvoiceStatus {
  draft, posted, partial, paid, cancelled;

  static InvoiceStatus fromBackend(String v) =>
      InvoiceStatus.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => InvoiceStatus.draft);

  String get label {
    switch (this) {
      case InvoiceStatus.draft: return 'Draft';
      case InvoiceStatus.posted: return 'Posted';
      case InvoiceStatus.partial: return 'Partial';
      case InvoiceStatus.paid: return 'Paid';
      case InvoiceStatus.cancelled: return 'Cancelled';
    }
  }
}

enum CancelledReason {
  customerRequested, wrongEntry;

  String get backendValue => name == 'customerRequested' ? 'CUSTOMER_REQUESTED' : 'WRONG_ENTRY';

  String get label => this == CancelledReason.customerRequested ? 'Customer Requested' : 'Wrong Entry';
}

class InvoiceItem {
  final int? id;
  final String description;
  final double quantity;
  final double unitPrice;
  final double discountPercent;
  final double vatRate;
  final double? discountAmount;
  final double? vatAmount;
  final double? subTotal;
  final double? lineTotal;

  InvoiceItem({
    this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0,
    this.vatRate = 0,
    this.discountAmount,
    this.vatAmount,
    this.subTotal,
    this.lineTotal,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> j) => InvoiceItem(
    id: j['id'],
    description: j['description'] ?? '',
    quantity: (j['quantity'] ?? 0).toDouble(),
    unitPrice: (j['unitPrice'] ?? 0).toDouble(),
    discountPercent: (j['discountPercent'] ?? 0).toDouble(),
    vatRate: (j['vatRate'] ?? 0).toDouble(),
    discountAmount: (j['discountAmount'] ?? 0).toDouble(),
    vatAmount: (j['vatAmount'] ?? 0).toDouble(),
    subTotal: (j['subTotal'] ?? 0).toDouble(),
    lineTotal: (j['lineTotal'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'description': description,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'discountPercent': discountPercent,
    'vatRate': vatRate,
  };

  // local (client-side) calculation, backend চূড়ান্ত মান পাঠাবে create/response এ
  double get computedSubTotal => quantity * unitPrice;
  double get computedDiscountAmount => computedSubTotal * (discountPercent / 100);
  double get computedAfterDiscount => computedSubTotal - computedDiscountAmount;
  double get computedVatAmount => computedAfterDiscount * (vatRate / 100);
  double get computedLineTotal => computedAfterDiscount + computedVatAmount;
}

class InvoiceModel {
  final int id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final int partyId;
  final String? partyName;
  final InvoiceStatus status;
  final int? paymentTerms;
  final String? reference;
  final String? notes;
  final double subTotal;
  final double discountAmount;
  final double vatAmount;
  final double grandTotal;
  final double paidAmount;
  final double dueAmount;
  final String? currencyCode;
  final bool approvalFeatureEnabled;
  final List<InvoiceItem> items;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.dueDate,
    required this.partyId,
    this.partyName,
    required this.status,
    this.paymentTerms,
    this.reference,
    this.notes,
    required this.subTotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.grandTotal,
    required this.paidAmount,
    required this.dueAmount,
    this.currencyCode,
    required this.approvalFeatureEnabled,
    required this.items,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> j) => InvoiceModel(
    id: j['id'],
    invoiceNumber: j['invoiceNumber'] ?? '',
    invoiceDate: DateTime.parse(j['invoiceDate']),
    dueDate: j['dueDate'] != null ? DateTime.tryParse(j['dueDate']) : null,
    partyId: j['partyId'],
    partyName: j['partyName'],
    status: InvoiceStatus.fromBackend(j['status'] ?? 'DRAFT'),
    paymentTerms: j['paymentTerms'],
    reference: j['reference'],
    notes: j['notes'],
    subTotal: (j['subTotal'] ?? 0).toDouble(),
    discountAmount: (j['discountAmount'] ?? 0).toDouble(),
    vatAmount: (j['vatAmount'] ?? 0).toDouble(),
    grandTotal: (j['grandTotal'] ?? 0).toDouble(),
    paidAmount: (j['paidAmount'] ?? 0).toDouble(),
    dueAmount: (j['dueAmount'] ?? 0).toDouble(),
    currencyCode: j['currencyCode'],
    approvalFeatureEnabled: j['approvalFeatureEnabled'] ?? false,
    items: (j['items'] as List? ?? []).map((e) => InvoiceItem.fromJson(e)).toList(),
  );
}

class InvoiceRequest {
  final int partyId;
  final DateTime invoiceDate;
  final int? paymentTerms;
  final String? currencyCode;
  final String? reference;
  final String? notes;
  final List<InvoiceItem> items;

  InvoiceRequest({
    required this.partyId,
    required this.invoiceDate,
    this.paymentTerms,
    this.currencyCode,
    this.reference,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'partyId': partyId,
    'invoiceDate': '${invoiceDate.year.toString().padLeft(4, '0')}-${invoiceDate.month.toString().padLeft(2, '0')}-${invoiceDate.day.toString().padLeft(2, '0')}',
    if (paymentTerms != null) 'paymentTerms': paymentTerms,
    if (currencyCode != null && currencyCode!.isNotEmpty) 'currencyCode': currencyCode,
    if (reference != null && reference!.isNotEmpty) 'reference': reference,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'items': items.map((i) => i.toJson()).toList(),
  };
}