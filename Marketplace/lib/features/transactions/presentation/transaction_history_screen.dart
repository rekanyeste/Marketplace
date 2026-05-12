import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../ratings/presentation/rate_user_dialog.dart';
import '../providers.dart';
import '../domain/transaction_record.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            tabs: [Tab(text: 'Purchases'), Tab(text: 'Sales')],
          ),
        ),
        body: TabBarView(children: [
          _TransactionList(
            provider: purchaseHistoryProvider,
            emptyLabel: 'No purchases yet',
            showRateButton: true,
          ),
          _TransactionList(
            provider: salesHistoryProvider,
            emptyLabel: 'No sales yet',
            showRateButton: false,
          ),
        ]),
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  final FutureProvider<List<TransactionRecord>> provider;
  final String emptyLabel;
  final bool showRateButton;

  const _TransactionList({
    required this.provider,
    required this.emptyLabel,
    required this.showRateButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(provider);
    return dataAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (txns) {
        if (txns.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: emptyLabel,
            subtitle: 'Completed transactions will appear here',
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: txns.length,
          itemBuilder: (_, i) {
            final tx = txns[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.listingTitle,
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat.yMMMd().add_jm().format(tx.completedAt),
                              style: AppTextStyles.caption,
                            ),
                          ]),
                    ),
                    Text(PriceFormatter.format(tx.price),
                        style: AppTextStyles.priceSmall),
                  ]),
                  if (showRateButton) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => showRateUserDialog(
                          context: context,
                          ref: ref,
                          toUid: tx.sellerId,
                          transactionId: tx.id,
                          listingTitle: tx.listingTitle,
                        ),
                        icon: const Icon(Icons.star_outline_rounded, size: 16),
                        label: const Text('Rate seller'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
      },
    );
  }
}
