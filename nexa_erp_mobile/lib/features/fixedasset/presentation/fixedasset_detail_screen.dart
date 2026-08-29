import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/fixedasset_provider.dart';
import '../data/fixedasset_models.dart';
import 'widgets/asset_disposal_form_sheet.dart';
import 'widgets/asset_status_style.dart';

class FixedAssetDetailScreen extends ConsumerWidget {
  final FixedAssetModel asset;
  const FixedAssetDetailScreen({super.key, required this.asset});

  Future<void> _runDepreciation(BuildContext context, WidgetRef ref) async {
    DateTime asOfDate = DateTime.now();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Run Depreciation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Run depreciation for ${asset.name} as of:'),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: dialogContext, initialDate: asOfDate, firstDate: DateTime(2015), lastDate: DateTime(2100));
                  if (picked != null) setState(() => asOfDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text(DateFormat('dd MMM yyyy').format(asOfDate)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Run')),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final ok = await ref.read(fixedAssetActionsProvider.notifier).runDepreciation(asset.id, asOfDate);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Depreciation posted successfully' : 'Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(depreciationHistoryProvider(asset.id));
    final depreciablePercent = asset.purchaseCost > 0 ? (asset.accumulatedDepreciation / (asset.purchaseCost - asset.salvageValue)).clamp(0, 1) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(asset.assetCode), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AssetStatusStyle.chipColor(asset.status), borderRadius: BorderRadius.circular(20)),
                      child: Text(asset.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AssetStatusStyle.color(asset.status))),
                    ),
                    Text(asset.depreciationMethod.label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(asset.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (asset.description != null && asset.description!.isNotEmpty)
                  Text(asset.description!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 14),
                const Text('Book Value', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(asset.bookValue.toStringAsFixed(2), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: depreciablePercent.toDouble(), minHeight: 8, backgroundColor: AppColors.chipBlue, color: AppColors.iconOrange),
                ),
                const SizedBox(height: 6),
                Text('${(depreciablePercent * 100).toStringAsFixed(1)}% depreciated', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _row('Purchase Date', DateFormat('dd MMM yyyy').format(asset.purchaseDate)),
                _row('Purchase Cost', asset.purchaseCost.toStringAsFixed(2)),
                _row('Salvage Value', asset.salvageValue.toStringAsFixed(2)),
                _row('Useful Life', '${asset.usefulLifeYears} years'),
                _row('Accumulated Depreciation', asset.accumulatedDepreciation.toStringAsFixed(2)),
                if (asset.lastDepreciationDate != null)
                  _row('Last Depreciation', DateFormat('dd MMM yyyy').format(asset.lastDepreciationDate!)),
                if (asset.status == AssetStatus.disposed) ...[
                  const Divider(),
                  if (asset.disposalDate != null) _row('Disposal Date', DateFormat('dd MMM yyyy').format(asset.disposalDate!)),
                  if (asset.disposalProceeds != null) _row('Disposal Proceeds', asset.disposalProceeds!.toStringAsFixed(2)),
                  if (asset.disposalGainLoss != null)
                    _row('Gain/Loss', asset.disposalGainLoss!.toStringAsFixed(2), valueColor: asset.disposalGainLoss! >= 0 ? AppColors.success : AppColors.danger),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (asset.status != AssetStatus.disposed) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _runDepreciation(context, ref),
                icon: const Icon(Icons.trending_down, size: 18),
                label: const Text('Run Depreciation'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.iconBlue),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => showAssetDisposalFormSheet(context, asset),
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                label: const Text('Dispose Asset', style: TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text('Depreciation History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          historyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (entries) {
              if (entries.isEmpty) {
                return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No depreciation entries yet', style: TextStyle(color: AppColors.textSecondary))));
              }
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: entries.map((e) => ListTile(
                    dense: true,
                    title: Text(DateFormat('dd MMM yyyy').format(e.periodDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    subtitle: Text('Book value after: ${e.bookValueAfter.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                    trailing: Text('-${e.depreciationAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger)),
                  )).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}