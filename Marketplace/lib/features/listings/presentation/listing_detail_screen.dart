import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../core/widgets/image_gallery.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/listing_card.dart';
import '../../auth/providers.dart';
import '../../chat/providers.dart';
import '../../favorites/providers.dart';
import '../providers.dart';
import 'listings_controller.dart';

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingStreamProvider(listingId));
    final currentUid = ref.watch(currentUserIdProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider).value ?? {};

    return listingAsync.when(
      loading:
          () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (listing) {
        if (listing == null) {
          return const Scaffold(body: Center(child: Text('Listing not found')));
        }

        final isOwner = listing.sellerId == currentUid;
        final isFavorited = favoriteIds.contains(listing.id);

        final similarAsync = ref.watch(
          similarListingsProvider((
            category: listing.category.name,
            excludeId: listing.id,
            city: listing.city,
          )),
        );

        return Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: CustomScrollView(
                slivers: [
                  // ── Image Gallery with app bar ──
                  SliverAppBar(
                    expandedHeight: AppSizes.detailImageHeight,
                    pinned: true,
                    backgroundColor: AppColors.scaffoldDark,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      if (!isOwner)
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isFavorited
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color:
                                  isFavorited ? AppColors.error : Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed:
                              () => ref
                                  .read(favoritesControllerProvider.notifier)
                                  .toggleFavorite(listing.id),
                        ),
                      if (isOwner)
                        PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onSelected: (v) async {
                            switch (v) {
                              case 'edit':
                                context.push('/edit-listing/${listing.id}');
                                break;
                              case 'sold':
                                await ref
                                    .read(listingsControllerProvider.notifier)
                                    .markAsSold(listing.id);
                                break;
                              case 'delete':
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: const Text('Delete Listing?'),
                                        content: const Text(
                                          'This action cannot be undone.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true && context.mounted) {
                                  await ref
                                      .read(listingsControllerProvider.notifier)
                                      .deleteListing(listing.id);
                                  if (context.mounted) context.pop();
                                }
                                break;
                            }
                          },
                          itemBuilder:
                              (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                if (listing.isActive)
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
                        ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: ImageGallery(
                        imageUrls: listing.imageUrls,
                        height: AppSizes.detailImageHeight,
                      ),
                    ),
                  ),

                  // ── Content ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status badge
                          if (listing.isSold)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'SOLD',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                          // Price
                          Text(
                            PriceFormatter.format(listing.price),
                            style: AppTextStyles.priceLarge,
                          ),
                          const SizedBox(height: 8),

                          // Title
                          Text(listing.title, style: AppTextStyles.h2),
                          const SizedBox(height: 12),

                          // Meta row
                          Row(
                            children: [
                              _MetaChip(
                                icon: Icons.location_on_outlined,
                                label: listing.city,
                              ),
                              const SizedBox(width: 8),
                              _MetaChip(
                                icon: Icons.access_time_rounded,
                                label: timeago.format(listing.createdAt),
                              ),
                              const SizedBox(width: 8),
                              _MetaChip(
                                icon: Icons.category_outlined,
                                label: listing.category.label,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _MetaChip(
                            icon: Icons.new_releases_outlined,
                            label: listing.condition.label,
                          ),
                          const SizedBox(height: 24),

                          // Description
                          Text('Description', style: AppTextStyles.h3),
                          const SizedBox(height: 8),
                          Text(
                            listing.description,
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(height: 24),

                          // Seller info
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.surfaceDark,
                                  child:
                                      listing.sellerImageUrl != null
                                          ? ClipOval(
                                            child: CachedImage(
                                              imageUrl: listing.sellerImageUrl,
                                              width: 48,
                                              height: 48,
                                            ),
                                          )
                                          : Text(
                                            listing.sellerName.isNotEmpty
                                                ? listing.sellerName[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                            ),
                                          ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listing.sellerName,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Seller',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isOwner && listing.isActive)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          if (currentUid == null) return;
                                          final threadId = await ref
                                              .read(chatRepositoryProvider)
                                              .createChatThread(
                                                buyerId: currentUid,
                                                sellerId: listing.sellerId,
                                                listingId: listing.id,
                                                listingTitle: listing.title,
                                              );
                                          if (context.mounted) {
                                            context.push('/chat/$threadId');
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 16,
                                        ),
                                        label: const Text('Chat'),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(0, 38),
                                          backgroundColor:
                                              AppColors.surfaceDark,
                                          foregroundColor:
                                              AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed:
                                            () => _confirmBuy(
                                              context,
                                              ref,
                                              listing,
                                            ),
                                        icon: const Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 16,
                                        ),
                                        label: const Text('Buy'),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(0, 38),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Similar Listings ──
                  SliverToBoxAdapter(
                    child: similarAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (similar) {
                        if (similar.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                              child: Text(
                                'Similar Listings',
                                style: AppTextStyles.h3,
                              ),
                            ),
                            SizedBox(
                              height: 260,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: similar.length,
                                itemBuilder:
                                    (_, i) => Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: SizedBox(
                                        width: 170,
                                        child: ListingCard(
                                          listing: similar[i],
                                          onTap:
                                              () => context.push(
                                                '/listing/${similar[i].id}',
                                              ),
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _confirmBuy(
  BuildContext context,
  WidgetRef ref,
  dynamic listing,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: const Text('Confirm Purchase'),
          content: Text(
            'Buy "${listing.title}" for ${listing.price.toStringAsFixed(0)} Ft?\n\n'
            'The seller will receive the payment and the listing will be marked as sold.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Buy now'),
            ),
          ],
        ),
  );

  if (confirmed != true || !context.mounted) return;

  final errorMessage = await ref
      .read(listingsControllerProvider.notifier)
      .buyListing(
        listingId: listing.id,
        sellerId: listing.sellerId,
        listingTitle: listing.title,
        price: listing.price,
      );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'Purchase successful!'),
        backgroundColor:
            errorMessage == null ? AppColors.success : AppColors.error,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
