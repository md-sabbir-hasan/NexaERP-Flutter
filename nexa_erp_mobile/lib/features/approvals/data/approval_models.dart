enum ApprovalStatus {
  pending, approved, rejected, returned, cancelled;

  static ApprovalStatus fromBackend(String v) =>
      ApprovalStatus.values.firstWhere((e) => e.name.toUpperCase() == v, orElse: () => ApprovalStatus.pending);

  String get label {
    switch (this) {
      case ApprovalStatus.pending: return 'Pending';
      case ApprovalStatus.approved: return 'Approved';
      case ApprovalStatus.rejected: return 'Rejected';
      case ApprovalStatus.returned: return 'Returned';
      case ApprovalStatus.cancelled: return 'Cancelled';
    }
  }
}

enum ApprovalEntityType {
  manualJournal, vendorBill, invoice, payment;

  static ApprovalEntityType fromBackend(String v) {
    switch (v) {
      case 'MANUAL_JOURNAL': return ApprovalEntityType.manualJournal;
      case 'VENDOR_BILL': return ApprovalEntityType.vendorBill;
      case 'INVOICE': return ApprovalEntityType.invoice;
      case 'PAYMENT': return ApprovalEntityType.payment;
      default: return ApprovalEntityType.manualJournal;
    }
  }

  String get label {
    switch (this) {
      case ApprovalEntityType.manualJournal: return 'Journal Entry';
      case ApprovalEntityType.vendorBill: return 'Vendor Bill';
      case ApprovalEntityType.invoice: return 'Invoice';
      case ApprovalEntityType.payment: return 'Payment';
    }
  }
}

class ApprovalAction {
  final int id;
  final String action;
  final int? actorUserId;
  final String? actorName;
  final ApprovalStatus? fromStatus;
  final ApprovalStatus? toStatus;
  final String? comment;
  final DateTime? createdAt;

  ApprovalAction({
    required this.id,
    required this.action,
    this.actorUserId,
    this.actorName,
    this.fromStatus,
    this.toStatus,
    this.comment,
    this.createdAt,
  });

  factory ApprovalAction.fromJson(Map<String, dynamic> j) => ApprovalAction(
    id: j['id'],
    action: j['action'] ?? '',
    actorUserId: j['actorUserId'],
    actorName: j['actorName'],
    fromStatus: j['fromStatus'] != null ? ApprovalStatus.fromBackend(j['fromStatus']) : null,
    toStatus: j['toStatus'] != null ? ApprovalStatus.fromBackend(j['toStatus']) : null,
    comment: j['comment'],
    createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
  );
}

class ApprovalRequest {
  final int id;
  final ApprovalEntityType entityType;
  final int entityId;
  final String? documentNumber;
  final String? documentTitle;
  final String? entityLabel;
  final int? makerUserId;
  final String? makerName;
  final ApprovalStatus status;
  final String? requiredPermission;
  final DateTime? submittedAt;
  final DateTime? decidedAt;
  final String? decisionComment;
  final bool canDecide;
  final List<ApprovalAction> actions;

  ApprovalRequest({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.documentNumber,
    this.documentTitle,
    this.entityLabel,
    this.makerUserId,
    this.makerName,
    required this.status,
    this.requiredPermission,
    this.submittedAt,
    this.decidedAt,
    this.decisionComment,
    required this.canDecide,
    this.actions = const [],
  });

  factory ApprovalRequest.fromJson(Map<String, dynamic> j) => ApprovalRequest(
    id: j['id'],
    entityType: ApprovalEntityType.fromBackend(j['entityType'] ?? 'MANUAL_JOURNAL'),
    entityId: j['entityId'],
    documentNumber: j['documentNumber'],
    documentTitle: j['documentTitle'],
    entityLabel: j['entityLabel'],
    makerUserId: j['makerUserId'],
    makerName: j['makerName'],
    status: ApprovalStatus.fromBackend(j['status'] ?? 'PENDING'),
    requiredPermission: j['requiredPermission'],
    submittedAt: j['submittedAt'] != null ? DateTime.tryParse(j['submittedAt']) : null,
    decidedAt: j['decidedAt'] != null ? DateTime.tryParse(j['decidedAt']) : null,
    decisionComment: j['decisionComment'],
    canDecide: j['canDecide'] ?? false,
    actions: (j['actions'] as List? ?? []).map((e) => ApprovalAction.fromJson(e)).toList(),
  );
}