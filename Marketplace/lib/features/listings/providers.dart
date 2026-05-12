import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/listings_repository.dart';
import 'data/storage_repository.dart';
import 'domain/listing.dart';

/// Provides ListingsRepository singleton.
final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepository();
});

/// Provides StorageRepository singleton.
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

/// Streams a single listing by ID.
final listingStreamProvider =
    StreamProvider.family<Listing?, String>((ref, id) {
  return ref.watch(listingsRepositoryProvider).streamListing(id);
});

/// Fetches recent listings for the home feed.
final recentListingsProvider = FutureProvider<List<Listing>>((ref) {
  return ref.watch(listingsRepositoryProvider).getRecentListings(limit: 20);
});

/// Fetches listings by city.
final cityListingsProvider =
    FutureProvider.family<List<Listing>, String>((ref, city) {
  return ref.watch(listingsRepositoryProvider).getListingsByCity(
        city: city,
        limit: 20,
      );
});

/// Fetches listings by category.
final categoryListingsProvider =
    FutureProvider.family<List<Listing>, String>((ref, category) {
  return ref.watch(listingsRepositoryProvider).getListingsByCategory(
        category: category,
        limit: 20,
      );
});

/// Fetches seller's active listings.
final sellerActiveListingsProvider =
    FutureProvider.family<List<Listing>, String>((ref, sellerId) {
  return ref.watch(listingsRepositoryProvider).getListingsBySeller(
        sellerId: sellerId,
        statusFilter: 'active',
      );
});

/// Fetches seller's sold listings.
final sellerSoldListingsProvider =
    FutureProvider.family<List<Listing>, String>((ref, sellerId) {
  return ref.watch(listingsRepositoryProvider).getListingsBySeller(
        sellerId: sellerId,
        statusFilter: 'sold',
      );
});

/// Similar listings provider.
final similarListingsProvider =
    FutureProvider.family<List<Listing>, ({String category, String excludeId, String? city})>(
        (ref, params) {
  return ref.watch(listingsRepositoryProvider).getSimilarListings(
        category: params.category,
        excludeId: params.excludeId,
        city: params.city,
      );
});
