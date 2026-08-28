enum CreditNoteStatus {
  draft, approved, posted, cancelled;

  static CreditNoteStatus fromBackend(String v) =>
      CreditNoteStatus.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => CreditNoteStatus.draft);

  String get label {
    switch (this) {
      case CreditNoteStatus.draft: return 'Draft';
      case CreditNoteStatus.approved: return 'Approved';
      case CreditNoteStatus.posted: return 'Posted';
      case CreditNoteStatus.cancelled: return 'Cancelled';
    }
  }
}

enum CreditNoteReason {
  salesReturn, priceAdjustment, postInvoiceDiscount, billingError, vatAdjustment, other;

  String get backendValue {
    switch (this) {
      case CreditNoteReason.salesReturn: return 'SALES_RETURN';
      case CreditNoteReason.priceAdjustment: return 'PRICE_ADJUSTMENT';
      case CreditNoteReason.postInvoiceDiscount: return 'POST_INVOICE_DISCOUNT';
      case CreditNoteReason.billingError: return 'BILLING_ERROR';
      case CreditNoteReason.vatAdjustment: return 'VAT_ADJUSTMENT';
      case CreditNoteReason.other: return 'OTHER';
    }
  }

  String get label {
    switch (this) {
      case CreditNoteReason.salesReturn: return 'Sales Return';
      case CreditNoteReason.priceAdjustment: return 'Price Adjustment';
      case CreditNoteReason.postInvoiceDiscount: return 'Post-Invoice Discount';
      case CreditNoteReason.billingError: return 'Billing Error';
      case CreditNoteReason.vatAdjustment: return 'VAT Adjustment';
      case CreditNoteReason.other: return 'Other';
    }
  }
}

enum CreditNoteCancelledReason {
  duplicate, wrongCustomer, wrongAmount, wrongReference, other;

  String get backendValue {
    switch (this) {
      case CreditNoteCancelledReason.duplicate: return 'DUPLICATE';
      case CreditNoteCancelledReason.wrongCustomer: return 'WRONG_CUSTOMER';
      case CreditNoteCancelledReason.wrongAmount: return 'WRONG_AMOUNT';
      case CreditNoteCancelledReason.wrongReference: return 'WRONG_REFERENCE';
      case CreditNoteCancelledReason.other: return 'OTHER';
    }
  }

  String get label {
    switch (this) {
      case CreditNoteCancelledReason.duplicate: return 'Duplicate';
      case CreditNoteCancelledReason.wrongCustomer: return 'Wrong Customer';
      case CreditNoteCancelledReason.wrongAmount: return 'Wrong Amount';
      case CreditNoteCancelledReason.wrongReference: return 'Wrong Reference';
      case CreditNoteCancelledReason.other: return 'Other';
    }
  }
}

class CreditNoteItemRequest {
  final int invoiceItemId;
  final double quantity;
  CreditNoteItemRequest({required this.invoiceItemId, required this.quantity});

  Map<String, dynamic> toJson() => {'invoiceItemId': invoiceItemId, 'quantity': quantity};
}

class CreditNoteItem {
  final int id;
  final int invoiceItemId;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double discountPercent;
  final double vatRate;
  final double lineTotal;

  CreditNoteItem({
    required this.id,
    required this.invoiceItemId,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discountPercent,
    required this.vatRate,
    required this.lineTotal,
  });

  factory CreditNoteItem.fromJson(Map<String, dynamic> j) => CreditNoteItem(
    id: j['id'],
    invoiceItemId: j['invoiceItemId'],
    description: j['description'],
    quantity: (j['quantity'] ?? 0).toDouble(),
    unitPrice: (j['unitPrice'] ?? 0).toDouble(),
    discountPercent: (j['discountPercent'] ?? 0).toDouble(),
    vatRate: (j['vatRate'] ?? 0).toDouble(),
    lineTotal: (j['lineTotal'] ?? 0).toDouble(),
  );
}

class CreditNoteModel {
  final int id;
  final String creditNoteNumber;
  final DateTime creditNoteDate;
  final int invoiceId;
  final String? invoiceNumber;
  final int partyId;
  final String? partyName;
  final CreditNoteStatus status;
  final CreditNoteReason reason;
  final String? reference;
  final String? notes;
  final double subTotal;
  final double discountAmount;
  final double vatAmount;
  final double grandTotal;
  final List<CreditNoteItem> items;

  CreditNoteModel({
    required this.id,
    required this.creditNoteNumber,
    required this.creditNoteDate,
    required this.invoiceId,
    this.invoiceNumber,
    required this.partyId,
    this.partyName,
    required this.status,
    required this.reason,
    this.reference,
    this.notes,
    required this.subTotal,
    required this.discountAmount,
    required this.vatAmount,
    required this.grandTotal,
    required this.items,
  });

  factory CreditNoteModel.fromJson(Map<String, dynamic> j) => CreditNoteModel(
    id: j['id'],
    creditNoteNumber: j['creditNoteNumber'] ?? '',
    creditNoteDate: DateTime.parse(j['creditNoteDate']),
    invoiceId: j['invoiceId'],
    invoiceNumber: j['invoiceNumber'],
    partyId: j['partyId'],
    partyName: j['partyName'],
    status: CreditNoteStatus.fromBackend(j['status'] ?? 'DRAFT'),
    reason: CreditNoteReason.values.firstWhere((r) => r.backendValue == j['reason'], orElse: () => CreditNoteReason.other),
    reference: j['reference'],
    notes: j['notes'],
    subTotal: (j['subTotal'] ?? 0).toDouble(),
    discountAmount: (j['discountAmount'] ?? 0).toDouble(),
    vatAmount: (j['vatAmount'] ?? 0).toDouble(),
    grandTotal: (j['grandTotal'] ?? 0).toDouble(),
    items: (j['items'] as List? ?? []).map((e) => CreditNoteItem.fromJson(e)).toList(),
  );
}

class CreditNoteRequest {
  final int invoiceId;
  final DateTime creditNoteDate;
  final CreditNoteReason reason;
  final String? reference;
  final String? notes;
  final List<CreditNoteItemRequest> items;

  CreditNoteRequest({
    required this.invoiceId,
    required this.creditNoteDate,
    required this.reason,
    this.reference,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'invoiceId': invoiceId,
    'creditNoteDate': '${creditNoteDate.year.toString().padLeft(4, '0')}-${creditNoteDate.month.toString().padLeft(2, '0')}-${creditNoteDate.day.toString().padLeft(2, '0')}',
    'reason': reason.backendValue,
    if (reference != null && reference!.isNotEmpty) 'reference': reference,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'items': items.map((i) => i.toJson()).toList(),
  };
}