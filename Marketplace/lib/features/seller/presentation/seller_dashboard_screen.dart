import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/providers.dart';
import '../../listings/domain/listing.dart';
import '../../listings/presentation/listings_controller.dart';
import '../../listings/providers.dart';
import '../../transactions/domain/transaction_record.dart';
import '../../transactions/providers.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final activeAsync = ref.watch(sellerActiveListingsProvider(uid));
    final soldAsync = ref.watch(sellerSoldListingsProvider(uid));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seller Dashboard'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            tabs: [Tab(text: 'Active'), Tab(text: 'Sold')],
          ),
        ),
        body: Column(
          children: [
            // Stats bar
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatBadge(
                    label: 'Active',
                    value: activeAsync.value?.length.toString() ?? '0',
                    icon: Icons.sell_outlined,
                  ),
                  _StatBadge(
                    label: 'Sold',
                    value: soldAsync.value?.length.toString() ?? '0',
                    icon: Icons.check_circle_outline,
                  ),
                  _StatBadge(
                    label: 'Revenue',
                    value: PriceFormatter.formatCompact(
                      (soldAsync.value ?? []).fold<double>(
                        0,
                        (sum, l) => sum + l.price,
                      ),
                    ),
                    icon: Icons.trending_up_rounded,
                  ),
                ],
              ),
            ),
            // Tabs
            Expanded(
              child: TabBarView(
                children: [
                  _ListingsList(
                    asyncListings: activeAsync,
                    emptyLabel: 'No active listings',
                    isActive: true,
                    ref: ref,
                    context: context,
                  ),
                  _ListingsList(
                    asyncListings: soldAsync,
                    emptyLabel: 'No sold listings',
                    isActive: false,
                    ref: ref,
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/create-listing'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Listing'),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _ListingsList extends StatelessWidget {
  final AsyncValue<List<Listing>> asyncListings;
  final String emptyLabel;
  final bool isActive;
  final WidgetRef ref;
  final BuildContext context;

  const _ListingsList({
    required this.asyncListings,
    required this.emptyLabel,
    required this.isActive,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext outerContext) {
    return asyncListings.when(
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (listings) {
        if (listings.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            title: emptyLabel,
            subtitle:
                isActive
                    ? 'Create a listing to start selling'
                    : 'Sold items will appear here',
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
          itemBuilder: (_, i) {
            final listing = listings[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedImage(
                    imageUrl:
                        listing.imageUrls.isNotEmpty
                            ? listing.imageUrls.first
                            : null,
                    width: 56,
                    height: 56,
                  ),
                ),
                title: Text(
                  listing.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  PriceFormatter.format(listing.price),
                  style: AppTextStyles.priceSmall,
                ),
                trailing:
                    isActive
                        ? PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppColors.textTertiary,
                          ),
                          onSelected: (v) async {
                            if (v == 'edit') {
                              context.push('/edit-listing/${listing.id}');
                            }
                            if (v == 'sold') {
                              await ref
                                  .read(listingsControllerProvider.notifier)
                                  .markAsSold(listing.id);
                              // Create transaction record
                              await ref
                                  .read(transactionsRepositoryProvider)
                                  .createTransaction(
                                    TransactionRecord(
                                      id: '',
                                      buyerId:
                                          '', // Would be set by actual buyer
                                      sellerId: listing.sellerId,
                                      listingId: listing.id,
                                      listingTitle: listing.title,
                                      price: listing.price,
                                      completedAt: DateTime.now(),
                                    ),
                                  );
                              ref.invalidate(
                                sellerActiveListingsProvider(listing.sellerId),
                              );
                              ref.invalidate(
                                sellerSoldListingsProvider(listing.sellerId),
                              );
                              ref.invalidate(salesHistoryProvider);
                            }
                            if (v == 'delete') {
                              await ref
                                  .read(listingsControllerProvider.notifier)
                                  .deleteListing(listing.id);
                              ref.invalidate(
                                sellerActiveListingsProvider(listing.sellerId),
                              );
                            }
                          },
                          itemBuilder:
                              (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'sold',
                                  child: Text('Mark as Sold'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                        )
                        : null,
                onTap: () => context.push('/listing/${listing.id}'),
              ),
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
