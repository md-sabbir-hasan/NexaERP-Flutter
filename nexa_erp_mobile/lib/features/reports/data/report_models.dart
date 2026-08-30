// ---------- Trial Balance ----------
class TrialBalanceRow {
  final int accountId;
  final String accountCode;
  final String accountName;
  final String accountType;
  final double debitBalance;
  final double creditBalance;

  TrialBalanceRow({required this.accountId, required this.accountCode, required this.accountName, required this.accountType, required this.debitBalance, required this.creditBalance});

  factory TrialBalanceRow.fromJson(Map<String, dynamic> j) => TrialBalanceRow(
    accountId: j['accountId'],
    accountCode: j['accountCode'] ?? '',
    accountName: j['accountName'] ?? '',
    accountType: j['accountType'] ?? '',
    debitBalance: (j['debitBalance'] ?? 0).toDouble(),
    creditBalance: (j['creditBalance'] ?? 0).toDouble(),
  );
}

class TrialBalanceReport {
  final DateTime asOfDate;
  final List<TrialBalanceRow> rows;
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;

  TrialBalanceReport({required this.asOfDate, required this.rows, required this.totalDebit, required this.totalCredit, required this.isBalanced});

  factory TrialBalanceReport.fromJson(Map<String, dynamic> j) => TrialBalanceReport(
    asOfDate: DateTime.parse(j['asOfDate']),
    rows: (j['rows'] as List? ?? []).map((e) => TrialBalanceRow.fromJson(e)).toList(),
    totalDebit: (j['totalDebit'] ?? 0).toDouble(),
    totalCredit: (j['totalCredit'] ?? 0).toDouble(),
    isBalanced: j['isBalanced'] ?? false,
  );
}

// ---------- Profit & Loss ----------
class ProfitLossRow {
  final int accountId;
  final String accountCode;
  final String accountName;
  final double amount;

  ProfitLossRow({required this.accountId, required this.accountCode, required this.accountName, required this.amount});

  factory ProfitLossRow.fromJson(Map<String, dynamic> j) => ProfitLossRow(
    accountId: j['accountId'],
    accountCode: j['accountCode'] ?? '',
    accountName: j['accountName'] ?? '',
    amount: (j['amount'] ?? 0).toDouble(),
  );
}

class ProfitLossReport {
  final DateTime fromDate;
  final DateTime toDate;
  final List<ProfitLossRow> revenues;
  final double totalRevenue;
  final List<ProfitLossRow> expenses;
  final double totalExpense;
  final double netProfit;

  ProfitLossReport({
    required this.fromDate, required this.toDate, required this.revenues, required this.totalRevenue,
    required this.expenses, required this.totalExpense, required this.netProfit,
  });

  factory ProfitLossReport.fromJson(Map<String, dynamic> j) => ProfitLossReport(
    fromDate: DateTime.parse(j['fromDate']),
    toDate: DateTime.parse(j['toDate']),
    revenues: (j['revenues'] as List? ?? []).map((e) => ProfitLossRow.fromJson(e)).toList(),
    totalRevenue: (j['totalRevenue'] ?? 0).toDouble(),
    expenses: (j['expenses'] as List? ?? []).map((e) => ProfitLossRow.fromJson(e)).toList(),
    totalExpense: (j['totalExpense'] ?? 0).toDouble(),
    netProfit: (j['netProfit'] ?? 0).toDouble(),
  );
}

// ---------- Balance Sheet ----------
class BalanceSheetRow {
  final int accountId;
  final String accountCode;
  final String accountName;
  final double amount;

  BalanceSheetRow({required this.accountId, required this.accountCode, required this.accountName, required this.amount});

  factory BalanceSheetRow.fromJson(Map<String, dynamic> j) => BalanceSheetRow(
    accountId: j['accountId'],
    accountCode: j['accountCode'] ?? '',
    accountName: j['accountName'] ?? '',
    amount: (j['amount'] ?? 0).toDouble(),
  );
}

class BalanceSheetReport {
  final DateTime asOfDate;
  final List<BalanceSheetRow> assets;
  final double totalAssets;
  final List<BalanceSheetRow> liabilities;
  final double totalLiabilities;
  final List<BalanceSheetRow> equity;
  final double totalEquityExcludingProfit;
  final double netProfit;
  final double totalEquity;
  final double totalLiabilitiesAndEquity;
  final bool isBalanced;

  BalanceSheetReport({
    required this.asOfDate, required this.assets, required this.totalAssets,
    required this.liabilities, required this.totalLiabilities,
    required this.equity, required this.totalEquityExcludingProfit,
    required this.netProfit, required this.totalEquity,
    required this.totalLiabilitiesAndEquity, required this.isBalanced,
  });

  factory BalanceSheetReport.fromJson(Map<String, dynamic> j) => BalanceSheetReport(
    asOfDate: DateTime.parse(j['asOfDate']),
    assets: (j['assets'] as List? ?? []).map((e) => BalanceSheetRow.fromJson(e)).toList(),
    totalAssets: (j['totalAssets'] ?? 0).toDouble(),
    liabilities: (j['liabilities'] as List? ?? []).map((e) => BalanceSheetRow.fromJson(e)).toList(),
    totalLiabilities: (j['totalLiabilities'] ?? 0).toDouble(),
    equity: (j['equity'] as List? ?? []).map((e) => BalanceSheetRow.fromJson(e)).toList(),
    totalEquityExcludingProfit: (j['totalEquityExcludingProfit'] ?? 0).toDouble(),
    netProfit: (j['netProfit'] ?? 0).toDouble(),
    totalEquity: (j['totalEquity'] ?? 0).toDouble(),
    totalLiabilitiesAndEquity: (j['totalLiabilitiesAndEquity'] ?? 0).toDouble(),
    isBalanced: j['isBalanced'] ?? false,
  );
}

// ---------- Ledger ----------
class LedgerEntry {
  final int journalEntryId;
  final DateTime date;
  final String journalEntryNumber;
  final String? sourceType;
  final String? referenceNumber;
  final String? description;
  final double debit;
  final double credit;
  final double runningBalance;

  LedgerEntry({
    required this.journalEntryId, required this.date, required this.journalEntryNumber, this.sourceType,
    this.referenceNumber, this.description, required this.debit, required this.credit, required this.runningBalance,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> j) => LedgerEntry(
    journalEntryId: j['journalEntryId'],
    date: DateTime.parse(j['date']),
    journalEntryNumber: j['journalEntryNumber'] ?? '',
    sourceType: j['sourceType'],
    referenceNumber: j['referenceNumber'],
    description: j['description'],
    debit: (j['debit'] ?? 0).toDouble(),
    credit: (j['credit'] ?? 0).toDouble(),
    runningBalance: (j['runningBalance'] ?? 0).toDouble(),
  );
}

class LedgerReport {
  final int accountId;
  final String accountCode;
  final String accountName;
  final DateTime fromDate;
  final DateTime toDate;
  final double openingBalance;
  final double closingBalance;
  final double totalDebit;
  final double totalCredit;
  final List<LedgerEntry> entries;

  LedgerReport({
    required this.accountId, required this.accountCode, required this.accountName,
    required this.fromDate, required this.toDate, required this.openingBalance, required this.closingBalance,
    required this.totalDebit, required this.totalCredit, required this.entries,
  });

  factory LedgerReport.fromJson(Map<String, dynamic> j) => LedgerReport(
    accountId: j['accountId'],
    accountCode: j['accountCode'] ?? '',
    accountName: j['accountName'] ?? '',
    fromDate: DateTime.parse(j['fromDate']),
    toDate: DateTime.parse(j['toDate']),
    openingBalance: (j['openingBalance'] ?? 0).toDouble(),
    closingBalance: (j['closingBalance'] ?? 0).toDouble(),
    totalDebit: (j['totalDebit'] ?? 0).toDouble(),
    totalCredit: (j['totalCredit'] ?? 0).toDouble(),
    entries: (j['entries'] as List? ?? []).map((e) => LedgerEntry.fromJson(e)).toList(),
  );
}