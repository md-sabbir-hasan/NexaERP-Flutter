import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../application/approval_provider.dart';
import 'widgets/approval_card.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('Approvals'),
          backgroundColor: AppColors.bg,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'My Requests'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ApprovalTabList(tab: ApprovalTab.pending),
            _ApprovalTabList(tab: ApprovalTab.myRequests),
          ],
        ),
      ),
    );
  }
}

class _ApprovalTabList extends ConsumerStatefulWidget {
  final ApprovalTab tab;
  const _ApprovalTabList({required this.tab});

  @override
  ConsumerState<_ApprovalTabList> createState() => _ApprovalTabListState();
}

class _ApprovalTabListState extends ConsumerState<_ApprovalTabList> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(approvalListProvider(widget.tab).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final listAsync = ref.watch(approvalListProvider(widget.tab));

    return listAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (state) {
        if (state.items.isEmpty) {
          final msg = widget.tab == ApprovalTab.pending ? 'কোনো pending approval নেই' : 'তোমার কোনো request নেই';
          return Center(child: Text(msg, style: const TextStyle(color: AppColors.textSecondary)));
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(approvalListProvider(widget.tab).notifier).refresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: state.items.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return ApprovalCard(request: state.items[index]);
            },
          ),
        );
      },
    );
  }
}