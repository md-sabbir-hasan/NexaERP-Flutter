enum DepreciationMethod {
  straightLine, reducingBalance;

  String get backendValue => this == DepreciationMethod.straightLine ? 'STRAIGHT_LINE' : 'REDUCING_BALANCE';
  static DepreciationMethod fromBackend(String v) =>
      v == 'REDUCING_BALANCE' ? DepreciationMethod.reducingBalance : DepreciationMethod.straightLine;

  String get label => this == DepreciationMethod.straightLine ? 'Straight Line' : 'Reducing Balance';
}

enum AssetStatus {
  active, fullyDepreciated, disposed;

  static AssetStatus fromBackend(String v) {
    switch (v) {
      case 'FULLY_DEPRECIATED': return AssetStatus.fullyDepreciated;
      case 'DISPOSED': return AssetStatus.disposed;
      default: return AssetStatus.active;
    }
  }

  String get label {
    switch (this) {
      case AssetStatus.active: return 'Active';
      case AssetStatus.fullyDepreciated: return 'Fully Depreciated';
      case AssetStatus.disposed: return 'Disposed';
    }
  }
}

class FixedAssetModel {
  final int id;
  final String assetCode;
  final String name;
  final String? description;
  final int assetAccountId;
  final String? assetAccountName;
  final int depreciationExpenseAccountId;
  final String? depreciationExpenseAccountName;
  final int accumulatedDepreciationAccountId;
  final String? accumulatedDepreciationAccountName;
  final DateTime purchaseDate;
  final double purchaseCost;
  final double salvageValue;
  final int usefulLifeYears;
  final DepreciationMethod depreciationMethod;
  final double? reducingBalanceRate;
  final double accumulatedDepreciation;
  final double bookValue;
  final AssetStatus status;
  final DateTime? lastDepreciationDate;
  final DateTime? disposalDate;
  final double? disposalProceeds;
  final double? disposalGainLoss;

  FixedAssetModel({
    required this.id,
    required this.assetCode,
    required this.name,
    this.description,
    required this.assetAccountId,
    this.assetAccountName,
    required this.depreciationExpenseAccountId,
    this.depreciationExpenseAccountName,
    required this.accumulatedDepreciationAccountId,
    this.accumulatedDepreciationAccountName,
    required this.purchaseDate,
    required this.purchaseCost,
    required this.salvageValue,
    required this.usefulLifeYears,
    required this.depreciationMethod,
    this.reducingBalanceRate,
    required this.accumulatedDepreciation,
    required this.bookValue,
    required this.status,
    this.lastDepreciationDate,
    this.disposalDate,
    this.disposalProceeds,
    this.disposalGainLoss,
  });

  factory FixedAssetModel.fromJson(Map<String, dynamic> j) => FixedAssetModel(
    id: j['id'],
    assetCode: j['assetCode'] ?? '',
    name: j['name'] ?? '',
    description: j['description'],
    assetAccountId: j['assetAccountId'],
    assetAccountName: j['assetAccountName'],
    depreciationExpenseAccountId: j['depreciationExpenseAccountId'],
    depreciationExpenseAccountName: j['depreciationExpenseAccountName'],
    accumulatedDepreciationAccountId: j['accumulatedDepreciationAccountId'],
    accumulatedDepreciationAccountName: j['accumulatedDepreciationAccountName'],
    purchaseDate: DateTime.parse(j['purchaseDate']),
    purchaseCost: (j['purchaseCost'] ?? 0).toDouble(),
    salvageValue: (j['salvageValue'] ?? 0).toDouble(),
    usefulLifeYears: j['usefulLifeYears'] ?? 1,
    depreciationMethod: DepreciationMethod.fromBackend(j['depreciationMethod'] ?? 'STRAIGHT_LINE'),
    reducingBalanceRate: j['reducingBalanceRate'] != null ? (j['reducingBalanceRate']).toDouble() : null,
    accumulatedDepreciation: (j['accumulatedDepreciation'] ?? 0).toDouble(),
    bookValue: (j['bookValue'] ?? 0).toDouble(),
    status: AssetStatus.fromBackend(j['status'] ?? 'ACTIVE'),
    lastDepreciationDate: j['lastDepreciationDate'] != null ? DateTime.tryParse(j['lastDepreciationDate']) : null,
    disposalDate: j['disposalDate'] != null ? DateTime.tryParse(j['disposalDate']) : null,
    disposalProceeds: j['disposalProceeds'] != null ? (j['disposalProceeds']).toDouble() : null,
    disposalGainLoss: j['disposalGainLoss'] != null ? (j['disposalGainLoss']).toDouble() : null,
  );
}

class FixedAssetRequest {
  final String name;
  final String? description;
  final int assetAccountId;
  final int depreciationExpenseAccountId;
  final int accumulatedDepreciationAccountId;
  final int paymentSourceAccountId;
  final DateTime purchaseDate;
  final double purchaseCost;
  final double salvageValue;
  final int usefulLifeYears;
  final DepreciationMethod depreciationMethod;
  final double? reducingBalanceRate;

  FixedAssetRequest({
    required this.name,
    this.description,
    required this.assetAccountId,
    required this.depreciationExpenseAccountId,
    required this.accumulatedDepreciationAccountId,
    required this.paymentSourceAccountId,
    required this.purchaseDate,
    required this.purchaseCost,
    required this.salvageValue,
    required this.usefulLifeYears,
    required this.depreciationMethod,
    this.reducingBalanceRate,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null && description!.isNotEmpty) 'description': description,
    'assetAccountId': assetAccountId,
    'depreciationExpenseAccountId': depreciationExpenseAccountId,
    'accumulatedDepreciationAccountId': accumulatedDepreciationAccountId,
    'paymentSourceAccountId': paymentSourceAccountId,
    'purchaseDate': '${purchaseDate.year.toString().padLeft(4, '0')}-${purchaseDate.month.toString().padLeft(2, '0')}-${purchaseDate.day.toString().padLeft(2, '0')}',
    'purchaseCost': purchaseCost,
    'salvageValue': salvageValue,
    'usefulLifeYears': usefulLifeYears,
    'depreciationMethod': depreciationMethod.backendValue,
    if (depreciationMethod == DepreciationMethod.reducingBalance && reducingBalanceRate != null) 'reducingBalanceRate': reducingBalanceRate,
  };
}

class AssetDisposalRequest {
  final DateTime disposalDate;
  final double disposalProceeds;
  final int? proceedsAccountId;
  final int? gainLossAccountId;
  final String? notes;

  AssetDisposalRequest({
    required this.disposalDate,
    required this.disposalProceeds,
    this.proceedsAccountId,
    this.gainLossAccountId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'disposalDate': '${disposalDate.year.toString().padLeft(4, '0')}-${disposalDate.month.toString().padLeft(2, '0')}-${disposalDate.day.toString().padLeft(2, '0')}',
    'disposalProceeds': disposalProceeds,
    if (proceedsAccountId != null) 'proceedsAccountId': proceedsAccountId,
    if (gainLossAccountId != null) 'gainLossAccountId': gainLossAccountId,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}

class DepreciationEntry {
  final int id;
  final int fixedAssetId;
  final String? assetCode;
  final String? assetName;
  final DateTime periodDate;
  final double depreciationAmount;
  final double accumulatedDepreciationAfter;
  final double bookValueAfter;

  DepreciationEntry({
    required this.id,
    required this.fixedAssetId,
    this.assetCode,
    this.assetName,
    required this.periodDate,
    required this.depreciationAmount,
    required this.accumulatedDepreciationAfter,
    required this.bookValueAfter,
  });

  factory DepreciationEntry.fromJson(Map<String, dynamic> j) => DepreciationEntry(
    id: j['id'],
    fixedAssetId: j['fixedAssetId'],
    assetCode: j['assetCode'],
    assetName: j['assetName'],
    periodDate: DateTime.parse(j['periodDate']),
    depreciationAmount: (j['depreciationAmount'] ?? 0).toDouble(),
    accumulatedDepreciationAfter: (j['accumulatedDepreciationAfter'] ?? 0).toDouble(),
    bookValueAfter: (j['bookValueAfter'] ?? 0).toDouble(),
  );
}