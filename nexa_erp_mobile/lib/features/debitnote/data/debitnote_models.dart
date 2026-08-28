enum DebitNoteStatus {
  draft, approved, posted, cancelled;

  static DebitNoteStatus fromBackend(String v) =>
      DebitNoteStatus.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => DebitNoteStatus.draft);

  String get label {
    switch (this) {
      case DebitNoteStatus.draft: return 'Draft';
      case DebitNoteStatus.approved: return 'Approved';
      case DebitNoteStatus.posted: return 'Posted';
      case DebitNoteStatus.cancelled: return 'Cancelled';
    }
  }
}

enum DebitNoteReason {
  salesReturn, priceAdjustment, postInvoiceDiscount, billingError, vatAdjustment, other;

  String get backendValue {
    switch (this) {
      case DebitNoteReason.salesReturn: return 'SALES_RETURN';
      case DebitNoteReason.priceAdjustment: return 'PRICE_ADJUSTMENT';
      case DebitNoteReason.postInvoiceDiscount: return 'POST_INVOICE_DISCOUNT';
      case DebitNoteReason.billingError: return 'BILLING_ERROR';
      case DebitNoteReason.vatAdjustment: return 'VAT_ADJUSTMENT';
      case DebitNoteReason.other: return 'OTHER';
    }
  }

  String get label {
    switch (this) {
      case DebitNoteReason.salesReturn: return 'Purchase Return';
      case DebitNoteReason.priceAdjustment: return 'Price Adjustment';
      case DebitNoteReason.postInvoiceDiscount: return 'Post-Bill Discount';
      case DebitNoteReason.billingError: return 'Billing Error';
      case DebitNoteReason.vatAdjustment: return 'VAT Adjustment';
      case DebitNoteReason.other: return 'Other';
    }
  }
}

enum DebitNoteCancelledReason {
  duplicate, wrongCustomer, wrongAmount, wrongReference, other;

  String get backendValue {
    switch (this) {
      case DebitNoteCancelledReason.duplicate: return 'DUPLICATE';
      case DebitNoteCancelledReason.wrongCustomer: return 'WRONG_CUSTOMER';
      case DebitNoteCancelledReason.wrongAmount: return 'WRONG_AMOUNT';
      case DebitNoteCancelledReason.wrongReference: return 'WRONG_REFERENCE';
      case DebitNoteCancelledReason.other: return 'OTHER';
    }
  }

  String get label {
    switch (this) {
      case DebitNoteCancelledReason.duplicate: return 'Duplicate';
      case DebitNoteCancelledReason.wrongCustomer: return 'Wrong Vendor';
      case DebitNoteCancelledReason.wrongAmount: return 'Wrong Amount';
      case DebitNoteCancelledReason.wrongReference: return 'Wrong Reference';
      case DebitNoteCancelledReason.other: return 'Other';
    }
  }
}

class DebitNoteItemRequest {
  final int vendorBillItemId;
  final double quantity;
  DebitNoteItemRequest({required this.vendorBillItemId, required this.quantity});

  Map<String, dynamic> toJson() => {'vendorBillItemId': vendorBillItemId, 'quantity': quantity};
}

class DebitNoteItem {
  final int id;
  final int vendorBillItemId;
  final int? expenseAccountId;
  final String? expenseAccountName;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double discountPercent;
  final double vatRate;
  final double tdsRate;
  final double lineTotal;
  final double netAdjustment;

  DebitNoteItem({
    required this.id,
    required this.vendorBillItemId,
    this.expenseAccountId,
    this.expenseAccountName,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discountPercent,
    required this.vatRate,
    required this.tdsRate,
    required this.lineTotal,
    required this.netAdjustment,
  });

  factory DebitNoteItem.fromJson(Map<String, dynamic> j) => DebitNoteItem(
    id: j['id'],
    vendorBillItemId: j['vendorBillItemId'],
    expenseAccountId: j['expenseAccountId'],
    expenseAccountName: j['expenseAccountName'],
    description: j['description'],
    quantity: (j['quantity'] ?? 0).toDouble(),
    unitPrice: (j['unitPrice'] ?? 0).toDouble(),
    discountPercent: (j['discountPercent'] ?? 0).toDouble(),
    vatRate: (j['vatRate'] ?? 0).toDouble(),
    tdsRate: (j['tdsRate'] ?? 0).toDouble(),
    lineTotal: (j['lineTotal'] ?? 0).toDouble(),
    netAdjustment: (j['netAdjustment'] ?? 0).toDouble(),
  );
}

class DebitNoteModel {
  final int id;
  final String debitNoteNumber;
  final DateTime debitNoteDate;
  final int vendorBillId;
  final String? vendorBillNumber;
  final int partyId;
  final String? partyName;
  final DebitNoteStatus status;
  final DebitNoteReason reason;
  final String? reference;
  final String? notes;
  final double subTotal;
  final double discountAmount;
  final double vatAmount;
  final double tdsAmount;
  final double grandTotal;
  final double netAdjustment;
  final List<DebitNoteItem> items;

  DebitNoteModel({
    required this.id,
    required this.debitNoteNumber,
    required this.debitNoteDate,
    required this.vendorBillId,
    this.vendorBillNumber,
    required this.partyId,
    this.partyName,
    required this.status,
    required this.reason,
    this.reference,
    this.notes,
    required this.subTotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.tdsAmount,
    required this.grandTotal,
    required this.netAdjustment,
    required this.items,
  });

  factory DebitNoteModel.fromJson(Map<String, dynamic> j) => DebitNoteModel(
    id: j['id'],
    debitNoteNumber: j['debitNoteNumber'] ?? '',
    debitNoteDate: DateTime.parse(j['debitNoteDate']),
    vendorBillId: j['vendorBillId'],
    vendorBillNumber: j['vendorBillNumber'],
    partyId: j['partyId'],
    partyName: j['partyName'],
    status: DebitNoteStatus.fromBackend(j['status'] ?? 'DRAFT'),
    reason: DebitNoteReason.values.firstWhere((r) => r.backendValue == j['reason'], orElse: () => DebitNoteReason.other),
    reference: j['reference'],
    notes: j['notes'],
    subTotal: (j['subTotal'] ?? 0).toDouble(),
    discountAmount: (j['discountAmount'] ?? 0).toDouble(),
    vatAmount: (j['vatAmount'] ?? 0).toDouble(),
    tdsAmount: (j['tdsAmount'] ?? 0).toDouble(),
    grandTotal: (j['grandTotal'] ?? 0).toDouble(),
    netAdjustment: (j['netAdjustment'] ?? 0).toDouble(),
    items: (j['items'] as List? ?? []).map((e) => DebitNoteItem.fromJson(e)).toList(),
  );
}

class DebitNoteRequest {
  final int vendorBillId;
  final DateTime debitNoteDate;
  final DebitNoteReason reason;
  final String? reference;
  final String? notes;
  final List<DebitNoteItemRequest> items;

  DebitNoteRequest({
    required this.vendorBillId,
    required this.debitNoteDate,
    required this.reason,
    this.reference,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'vendorBillId': vendorBillId,
    'debitNoteDate': '${debitNoteDate.year.toString().padLeft(4, '0')}-${debitNoteDate.month.toString().padLeft(2, '0')}-${debitNoteDate.day.toString().padLeft(2, '0')}',
    'reason': reason.backendValue,
    if (reference != null && reference!.isNotEmpty) 'reference': reference,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'items': items.map((i) => i.toJson()).toList(),
  };
}