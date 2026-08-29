enum BankAccountType {
  cash, bank, mobileWallet;

  String get backendValue {
    switch (this) {
      case BankAccountType.cash: return 'CASH';
      case BankAccountType.bank: return 'BANK';
      case BankAccountType.mobileWallet: return 'MOBILE_WALLET';
    }
  }

  static BankAccountType fromBackend(String v) =>
      BankAccountType.values.firstWhere((e) => e.backendValue == v, orElse: () => BankAccountType.bank);

  String get label {
    switch (this) {
      case BankAccountType.cash: return 'Cash';
      case BankAccountType.bank: return 'Bank';
      case BankAccountType.mobileWallet: return 'Mobile Wallet';
    }
  }
}

enum WalletProvider {
  bkash, nagad, rocket;

  String get backendValue => name.toUpperCase();
  static WalletProvider fromBackend(String v) =>
      WalletProvider.values.firstWhere((e) => e.backendValue == v, orElse: () => WalletProvider.bkash);

  String get label {
    switch (this) {
      case WalletProvider.bkash: return 'bKash';
      case WalletProvider.nagad: return 'Nagad';
      case WalletProvider.rocket: return 'Rocket';
    }
  }
}

enum TransactionType {
  credit, debit;

  String get backendValue => name.toUpperCase();
  static TransactionType fromBackend(String v) =>
      TransactionType.values.firstWhere((e) => e.backendValue == v, orElse: () => TransactionType.credit);

  String get label => this == TransactionType.credit ? 'Money In (Credit)' : 'Money Out (Debit)';
}

class BankAccountModel {
  final int id;
  final String accountName;
  final String? accountNumber;
  final String? bankName;
  final String? branchName;
  final BankAccountType accountType;
  final String? currency;
  final double openingBalance;
  final double currentBalance;
  final bool isActive;
  final String? notes;
  final String? mobileNumber;
  final WalletProvider? walletProvider;
  final int? coaAccountId;

  BankAccountModel({
    required this.id,
    required this.accountName,
    this.accountNumber,
    this.bankName,
    this.branchName,
    required this.accountType,
    this.currency,
    required this.openingBalance,
    required this.currentBalance,
    required this.isActive,
    this.notes,
    this.mobileNumber,
    this.walletProvider,
    this.coaAccountId,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> j) => BankAccountModel(
    id: j['id'],
    accountName: j['accountName'] ?? '',
    accountNumber: j['accountNumber'],
    bankName: j['bankName'],
    branchName: j['branchName'],
    accountType: BankAccountType.fromBackend(j['accountType'] ?? 'BANK'),
    currency: j['currency'],
    openingBalance: (j['openingBalance'] ?? 0).toDouble(),
    currentBalance: (j['currentBalance'] ?? 0).toDouble(),
    isActive: j['isActive'] ?? true,
    notes: j['notes'],
    mobileNumber: j['mobileNumber'],
    walletProvider: j['walletProvider'] != null ? WalletProvider.fromBackend(j['walletProvider']) : null,
    coaAccountId: j['coaAccountId'],
  );
}

class BankAccountRequest {
  final String accountName;
  final String? accountNumber;
  final String? bankName;
  final String? branchName;
  final BankAccountType accountType;
  final String? currency;
  final double? openingBalance;
  final String? notes;
  final String? mobileNumber;
  final WalletProvider? walletProvider;
  final int? coaAccountId;

  BankAccountRequest({
    required this.accountName,
    this.accountNumber,
    this.bankName,
    this.branchName,
    required this.accountType,
    this.currency,
    this.openingBalance,
    this.notes,
    this.mobileNumber,
    this.walletProvider,
    this.coaAccountId,
  });

  Map<String, dynamic> toJson() => {
    'accountName': accountName,
    if (accountNumber != null && accountNumber!.isNotEmpty) 'accountNumber': accountNumber,
    if (bankName != null && bankName!.isNotEmpty) 'bankName': bankName,
    if (branchName != null && branchName!.isNotEmpty) 'branchName': branchName,
    'accountType': accountType.backendValue,
    if (currency != null && currency!.isNotEmpty) 'currency': currency,
    if (openingBalance != null) 'openingBalance': openingBalance,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    if (mobileNumber != null && mobileNumber!.isNotEmpty) 'mobileNumber': mobileNumber,
    if (walletProvider != null) 'walletProvider': walletProvider!.backendValue,
    if (coaAccountId != null) 'coaAccountId': coaAccountId,
  };
}

class BankTransactionModel {
  final int id;
  final String transactionNumber;
  final int bankAccountId;
  final String? bankAccountName;
  final DateTime transactionDate;
  final TransactionType transactionType;
  final double amount;
  final String? description;
  final String? referenceNumber;
  final int? contraAccountId;
  final String? contraAccountName;
  final bool reconciled;
  final bool voided;
  final String? sourceType;
  final DateTime? createdAt;

  BankTransactionModel({
    required this.id,
    required this.transactionNumber,
    required this.bankAccountId,
    this.bankAccountName,
    required this.transactionDate,
    required this.transactionType,
    required this.amount,
    this.description,
    this.referenceNumber,
    this.contraAccountId,
    this.contraAccountName,
    required this.reconciled,
    required this.voided,
    this.sourceType,
    this.createdAt,
  });

  factory BankTransactionModel.fromJson(Map<String, dynamic> j) => BankTransactionModel(
    id: j['id'],
    transactionNumber: j['transactionNumber'] ?? '',
    bankAccountId: j['bankAccountId'],
    bankAccountName: j['bankAccountName'],
    transactionDate: DateTime.parse(j['transactionDate']),
    transactionType: TransactionType.fromBackend(j['transactionType'] ?? 'CREDIT'),
    amount: (j['amount'] ?? 0).toDouble(),
    description: j['description'],
    referenceNumber: j['referenceNumber'],
    contraAccountId: j['contraAccountId'],
    contraAccountName: j['contraAccountName'],
    reconciled: j['reconciled'] ?? false,
    voided: j['voided'] ?? false,
    sourceType: j['sourceType'],
    createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
  );
}

class BankTransactionRequest {
  final int bankAccountId;
  final DateTime transactionDate;
  final TransactionType transactionType;
  final double amount;
  final String? description;
  final String? referenceNumber;
  final int contraAccountId;

  BankTransactionRequest({
    required this.bankAccountId,
    required this.transactionDate,
    required this.transactionType,
    required this.amount,
    this.description,
    this.referenceNumber,
    required this.contraAccountId,
  });

  Map<String, dynamic> toJson() => {
    'bankAccountId': bankAccountId,
    'transactionDate': '${transactionDate.year.toString().padLeft(4, '0')}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}',
    'transactionType': transactionType.backendValue,
    'amount': amount,
    if (description != null && description!.isNotEmpty) 'description': description,
    if (referenceNumber != null && referenceNumber!.isNotEmpty) 'referenceNumber': referenceNumber,
    'contraAccountId': contraAccountId,
  };
}

class BankTransferRequest {
  final int fromBankAccountId;
  final int toBankAccountId;
  final DateTime transactionDate;
  final double amount;
  final String? description;
  final String? referenceNumber;

  BankTransferRequest({
    required this.fromBankAccountId,
    required this.toBankAccountId,
    required this.transactionDate,
    required this.amount,
    this.description,
    this.referenceNumber,
  });

  Map<String, dynamic> toJson() => {
    'fromBankAccountId': fromBankAccountId,
    'toBankAccountId': toBankAccountId,
    'transactionDate': '${transactionDate.year.toString().padLeft(4, '0')}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}',
    'amount': amount,
    if (description != null && description!.isNotEmpty) 'description': description,
    if (referenceNumber != null && referenceNumber!.isNotEmpty) 'referenceNumber': referenceNumber,
  };
}