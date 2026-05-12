import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/listing_card.dart';
import '../providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(favoriteListingsProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider).value ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Items')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: listingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(favoriteListingsProvider)),
        data: (listings) {
          if (listings.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No saved items',
              subtitle: 'Items you save will appear here',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(favoriteListingsProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridColumns(context),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: Responsive.gridAspectRatio(context),
              ),
              itemCount: listings.length,
              itemBuilder: (_, i) {
                final listing = listings[i];
                return ListingCard(
                  listing: listing,
                  isFavorited: favoriteIds.contains(listing.id),
                  onTap: () => context.push('/listing/${listing.id}'),
                  onFavorite: () => ref.read(favoritesControllerProvider.notifier).toggleFavorite(listing.id),
                );
              },
            ),
          );
        },
      ),
      ),
    ),
    );
  }
}
