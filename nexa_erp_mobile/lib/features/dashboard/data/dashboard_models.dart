class DashboardSummary {
  final UserSummary users;
  final SecuritySummary security;
  final FinanceSummary finance;
  final BusinessSummary business;
  final SystemSummary system;
  final List<RecentActivity> recentActivities;
  final BudgetDashboard budget;
  final ExpenseDashboard expense;

  DashboardSummary({
    required this.users,
    required this.security,
    required this.finance,
    required this.business,
    required this.system,
    required this.recentActivities,
    required this.budget,
    required this.expense,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      users: UserSummary.fromJson(json['users'] ?? {}),
      security: SecuritySummary.fromJson(json['security'] ?? {}),
      finance: FinanceSummary.fromJson(json['finance'] ?? {}),
      business: BusinessSummary.fromJson(json['business'] ?? {}),
      system: SystemSummary.fromJson(json['system'] ?? {}),
      recentActivities: (json['recentActivities'] as List? ?? [])
          .map((e) => RecentActivity.fromJson(e))
          .toList(),
      budget: BudgetDashboard.fromJson(json['budget'] ?? {}),
      expense: ExpenseDashboard.fromJson(json['expense'] ?? {}),
    );
  }
}

class UserSummary {
  final int total, active, pending, inactive, locked;
  UserSummary({required this.total, required this.active, required this.pending, required this.inactive, required this.locked});
  factory UserSummary.fromJson(Map<String, dynamic> j) => UserSummary(
    total: j['total'] ?? 0, active: j['active'] ?? 0, pending: j['pending'] ?? 0,
    inactive: j['inactive'] ?? 0, locked: j['locked'] ?? 0,
  );
}

class SecuritySummary {
  final int totalRoles, totalPermissions;
  SecuritySummary({required this.totalRoles, required this.totalPermissions});
  factory SecuritySummary.fromJson(Map<String, dynamic> j) =>
      SecuritySummary(totalRoles: j['totalRoles'] ?? 0, totalPermissions: j['totalPermissions'] ?? 0);
}

class FinanceSummary {
  final int totalAccounts, totalJournalEntries, postedJournalEntries, draftJournalEntries, reversedJournalEntries;
  FinanceSummary({
    required this.totalAccounts, required this.totalJournalEntries, required this.postedJournalEntries,
    required this.draftJournalEntries, required this.reversedJournalEntries,
  });
  factory FinanceSummary.fromJson(Map<String, dynamic> j) => FinanceSummary(
    totalAccounts: j['totalAccounts'] ?? 0,
    totalJournalEntries: j['totalJournalEntries'] ?? 0,
    postedJournalEntries: j['postedJournalEntries'] ?? 0,
    draftJournalEntries: j['draftJournalEntries'] ?? 0,
    reversedJournalEntries: j['reversedJournalEntries'] ?? 0,
  );
}

class MonthlyTrend {
  final String month;
  final double amount;
  MonthlyTrend({required this.month, required this.amount});
  factory MonthlyTrend.fromJson(Map<String, dynamic> j) =>
      MonthlyTrend(month: j['month'] ?? '', amount: (j['amount'] ?? 0).toDouble());
}

class BusinessSummary {
  final double cashPosition;
  final bool cashConfigured;
  final String? currencyCode;
  final double accountsReceivable;
  final int overdueInvoiceCount;
  final double overdueInvoiceAmount;
  final double accountsPayable;
  final int overdueBillCount;
  final double overdueBillAmount;
  final List<MonthlyTrend> revenueTrend;
  final List<MonthlyTrend> expenseTrend;
  final double currentMonthRevenue;
  final double currentMonthExpense;

  BusinessSummary({
    required this.cashPosition, required this.cashConfigured, this.currencyCode,
    required this.accountsReceivable, required this.overdueInvoiceCount, required this.overdueInvoiceAmount,
    required this.accountsPayable, required this.overdueBillCount, required this.overdueBillAmount,
    required this.revenueTrend, required this.expenseTrend,
    required this.currentMonthRevenue, required this.currentMonthExpense,
  });

  factory BusinessSummary.fromJson(Map<String, dynamic> j) => BusinessSummary(
    cashPosition: (j['cashPosition'] ?? 0).toDouble(),
    cashConfigured: j['cashConfigured'] ?? false,
    currencyCode: j['currencyCode'],
    accountsReceivable: (j['accountsReceivable'] ?? 0).toDouble(),
    overdueInvoiceCount: j['overdueInvoiceCount'] ?? 0,
    overdueInvoiceAmount: (j['overdueInvoiceAmount'] ?? 0).toDouble(),
    accountsPayable: (j['accountsPayable'] ?? 0).toDouble(),
    overdueBillCount: j['overdueBillCount'] ?? 0,
    overdueBillAmount: (j['overdueBillAmount'] ?? 0).toDouble(),
    revenueTrend: (j['revenueTrend'] as List? ?? []).map((e) => MonthlyTrend.fromJson(e)).toList(),
    expenseTrend: (j['expenseTrend'] as List? ?? []).map((e) => MonthlyTrend.fromJson(e)).toList(),
    currentMonthRevenue: (j['currentMonthRevenue'] ?? 0).toDouble(),
    currentMonthExpense: (j['currentMonthExpense'] ?? 0).toDouble(),
  );
}

class SystemSummary {
  final String? applicationVersion, serverTimezone, environment, javaVersion;
  SystemSummary({this.applicationVersion, this.serverTimezone, this.environment, this.javaVersion});
  factory SystemSummary.fromJson(Map<String, dynamic> j) => SystemSummary(
    applicationVersion: j['applicationVersion'],
    serverTimezone: j['serverTimezone'],
    environment: j['environment'],
    javaVersion: j['javaVersion'],
  );
}

class RecentActivity {
  final String? action, entityName, userName, description;
  final int? entityId;
  final DateTime? createdAt;
  RecentActivity({this.action, this.entityName, this.entityId, this.userName, this.createdAt, this.description});
  factory RecentActivity.fromJson(Map<String, dynamic> j) => RecentActivity(
    action: j['action'],
    entityName: j['entityName'],
    entityId: j['entityId'],
    userName: j['userName'],
    createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
    description: j['description'],
  );
}

class BudgetTopAccount {
  final String? accountCode, accountName;
  final double budgetAmount, actualAmount, utilizationPercent;
  BudgetTopAccount({this.accountCode, this.accountName, required this.budgetAmount, required this.actualAmount, required this.utilizationPercent});
  factory BudgetTopAccount.fromJson(Map<String, dynamic> j) => BudgetTopAccount(
    accountCode: j['accountCode'],
    accountName: j['accountName'],
    budgetAmount: (j['budgetAmount'] ?? 0).toDouble(),
    actualAmount: (j['actualAmount'] ?? 0).toDouble(),
    utilizationPercent: (j['utilizationPercent'] ?? 0).toDouble(),
  );
}

class BudgetDashboard {
  final bool hasActiveBudget;
  final String? activeBudgetName, unavailableReason, currencyCode;
  final double totalExpenseBudget, totalExpenseActualYtd, expenseUtilizationPercent;
  final double totalRevenueBudget, totalRevenueActualYtd, revenueAchievementPercent;
  final List<BudgetTopAccount> topAccounts;

  BudgetDashboard({
    required this.hasActiveBudget, this.activeBudgetName, this.unavailableReason, this.currencyCode,
    required this.totalExpenseBudget, required this.totalExpenseActualYtd, required this.expenseUtilizationPercent,
    required this.totalRevenueBudget, required this.totalRevenueActualYtd, required this.revenueAchievementPercent,
    required this.topAccounts,
  });

  factory BudgetDashboard.fromJson(Map<String, dynamic> j) => BudgetDashboard(
    hasActiveBudget: j['hasActiveBudget'] ?? false,
    activeBudgetName: j['activeBudgetName'],
    unavailableReason: j['unavailableReason'],
    currencyCode: j['currencyCode'],
    totalExpenseBudget: (j['totalExpenseBudget'] ?? 0).toDouble(),
    totalExpenseActualYtd: (j['totalExpenseActualYtd'] ?? 0).toDouble(),
    expenseUtilizationPercent: (j['expenseUtilizationPercent'] ?? 0).toDouble(),
    totalRevenueBudget: (j['totalRevenueBudget'] ?? 0).toDouble(),
    totalRevenueActualYtd: (j['totalRevenueActualYtd'] ?? 0).toDouble(),
    revenueAchievementPercent: (j['revenueAchievementPercent'] ?? 0).toDouble(),
    topAccounts: (j['topAccounts'] as List? ?? []).map((e) => BudgetTopAccount.fromJson(e)).toList(),
  );
}

class ExpenseDashboard {
  final int draftCount;
  final double draftTotalAmount, postedThisMonthTotal, outstandingDue;
  final int recurringActiveCount, recurringDueSoonCount;

  ExpenseDashboard({
    required this.draftCount, required this.draftTotalAmount, required this.postedThisMonthTotal,
    required this.recurringActiveCount, required this.recurringDueSoonCount, required this.outstandingDue,
  });

  factory ExpenseDashboard.fromJson(Map<String, dynamic> j) => ExpenseDashboard(
    draftCount: j['draftCount'] ?? 0,
    draftTotalAmount: (j['draftTotalAmount'] ?? 0).toDouble(),
    postedThisMonthTotal: (j['postedThisMonthTotal'] ?? 0).toDouble(),
    recurringActiveCount: j['recurringActiveCount'] ?? 0,
    recurringDueSoonCount: j['recurringDueSoonCount'] ?? 0,
    outstandingDue: (j['outstandingDue'] ?? 0).toDouble(),
  );
}

class DashboardWorkflowSummary {
  final bool approvalEnabled;
  final int availablePendingCount, myPendingCount, myReturnedCount, myApprovedUnconsumedCount;

  DashboardWorkflowSummary({
    required this.approvalEnabled, required this.availablePendingCount,
    required this.myPendingCount, required this.myReturnedCount, required this.myApprovedUnconsumedCount,
  });

  factory DashboardWorkflowSummary.fromJson(Map<String, dynamic> j) => DashboardWorkflowSummary(
    approvalEnabled: j['approvalEnabled'] ?? false,
    availablePendingCount: j['availablePendingCount'] ?? 0,
    myPendingCount: j['myPendingCount'] ?? 0,
    myReturnedCount: j['myReturnedCount'] ?? 0,
    myApprovedUnconsumedCount: j['myApprovedUnconsumedCount'] ?? 0,
  );
}