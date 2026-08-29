import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/fixedasset_provider.dart';
import '../data/fixedasset_models.dart';
import 'create_fixedasset_screen.dart';
import 'fixedasset_detail_screen.dart';
import 'widgets/asset_status_style.dart';

class FixedAssetListScreen extends ConsumerWidget {
  const FixedAssetListScreen({super.key});

  Future<void> _runDepreciationForAll(BuildContext context, WidgetRef ref) async {
    DateTime asOfDate = DateTime.now();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Run Depreciation for All Assets'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will run depreciation for every eligible asset as of:'),
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

    final ok = await ref.read(fixedAssetActionsProvider.notifier).runDepreciationForAll(asOfDate);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Depreciation run completed for all assets' : 'Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(fixedAssetListProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Fixed Assets'),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_check, size: 22),
            tooltip: 'Run depreciation for all',
            onPressed: () => _runDepreciationForAll(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateFixedAssetScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: assetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (assets) {
          if (assets.isEmpty) {
            return const Center(child: Text('No fixed assets found', style: TextStyle(color: AppColors.textSecondary)));
          }
          final totalBookValue = assets.where((a) => a.status != AssetStatus.disposed).fold(0.0, (s, a) => s + a.bookValue);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(fixedAssetListProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Net Book Value', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(totalBookValue.toStringAsFixed(2), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...assets.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FixedAssetDetailScreen(asset: a))),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AssetStatusStyle.chipColor(a.status), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.inventory_2_outlined, color: AssetStatusStyle.color(a.status), size: 18),
                    ),
                    title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${a.assetCode} · ${a.status.label}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    trailing: Text(a.bookValue.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}