enum NotificationType {
  system, userInvitation, invoiceOverdue, invoicePayment, invoicePosted, invoiceCancelled,
  vendorBillDue, vendorBillOverdue, vendorBillPayment, vendorBillPosted, vendorBillCancelled,
  budgetWarning, budgetExceeded, accountingPeriod, expense, recurringExpense, payment,
  paymentPosted, banking, fixedAsset, journalDraftPending, recurringExpenseDraftPending,
  accountingPeriodClosed, accountingPeriodLocked, approvalSubmitted, approvalApproved,
  approvalRejected, approvalReturned, unknown;

  static NotificationType fromBackend(String? value) {
    if (value == null) return NotificationType.unknown;
    final snake = value.toLowerCase().split('_');
    final camel = snake.first + snake.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
    return NotificationType.values.firstWhere(
          (e) => e.name == camel,
      orElse: () => NotificationType.unknown,
    );
  }
}

enum NotificationPriority { low, medium, high, critical;

  static NotificationPriority fromBackend(String? value) {
    return NotificationPriority.values.firstWhere(
          (e) => e.name == value?.toLowerCase(),
      orElse: () => NotificationPriority.low,
    );
  }
}

class AppNotification {
  final int id;
  final NotificationType type;
  final NotificationPriority priority;
  final String? module;
  final String title;
  final String message;
  final String? route;
  final String? entityType;
  final int? entityId;
  final bool read;
  final DateTime? readAt;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.priority,
    this.module,
    required this.title,
    required this.message,
    this.route,
    this.entityType,
    this.entityId,
    required this.read,
    this.readAt,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['id'],
    type: NotificationType.fromBackend(j['type']),
    priority: NotificationPriority.fromBackend(j['priority']),
    module: j['module'],
    title: j['title'] ?? '',
    message: j['message'] ?? '',
    route: j['route'],
    entityType: j['entityType'],
    entityId: j['entityId'],
    read: j['read'] ?? false,
    readAt: j['readAt'] != null ? DateTime.tryParse(j['readAt']) : null,
    createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
  );

  AppNotification copyWith({bool? read, DateTime? readAt}) => AppNotification(
    id: id, type: type, priority: priority, module: module, title: title,
    message: message, route: route, entityType: entityType, entityId: entityId,
    read: read ?? this.read, readAt: readAt ?? this.readAt, createdAt: createdAt,
  );
}