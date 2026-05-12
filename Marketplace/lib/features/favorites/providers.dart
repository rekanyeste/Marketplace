import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers.dart';
import '../listings/domain/listing.dart';
import '../listings/providers.dart';
import 'data/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

/// Streams the set of favorited listing IDs for the current user.
final favoriteIdsProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value({});
  return ref.watch(favoritesRepositoryProvider).streamFavoriteIds(uid);
});

/// Fetches the actual listing objects for favorites.
/// Watches favoriteIdsProvider so it auto-refreshes when the user adds/removes.
final favoriteListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final ids = ref.watch(favoriteIdsProvider).value;
  if (ids == null) return [];   // still loading stream
  if (ids.isEmpty) return [];

  final listingsRepo = ref.watch(listingsRepositoryProvider);
  final listings = <Listing>[];
  for (final id in ids) {
    final listing = await listingsRepo.getListing(id);
    if (listing != null) listings.add(listing);
  }
  return listings;
});

/// Controller for toggling favorites.
class FavoritesController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> toggleFavorite(String listingId) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    final repo = ref.read(favoritesRepositoryProvider);
    final isFav = await repo.isFavorited(uid, listingId);

    if (isFav) {
      await repo.removeFavorite(uid, listingId);
    } else {
      await repo.addFavorite(uid, listingId);
    }
  }
}

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, void>(FavoritesController.new);
