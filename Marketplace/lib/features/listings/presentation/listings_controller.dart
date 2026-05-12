import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/image_helper.dart';
import '../data/listings_repository.dart';
import '../domain/listing.dart';
import '../domain/listing_category.dart';
import '../providers.dart';
import '../../auth/providers.dart';
import '../../profile/providers.dart';
import '../../transactions/domain/transaction_record.dart';
import '../../transactions/providers.dart';

/// Controller for listing CRUD operations.
class ListingsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  ListingsRepository get _listingsRepo => ref.read(listingsRepositoryProvider);

  /// Create a new listing with images stored as Base64.
  Future<String?> createListing({
    required String title,
    required String description,
    required ListingCategory category,
    required double price,
    required ListingCondition condition,
    required String city,
    required List<File> imageFiles,
  }) async {
    state = const AsyncLoading();
    String? listingId;

    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider);
      final profile = await ref.read(currentProfileProvider.future);
      if (user == null || profile == null) {
        throw Exception('Not authenticated');
      }

      final now = DateTime.now();
      final keywords = Listing.generateSearchKeywords(title, description);

      // Convert images to Base64
      final imageBase64 = await ImageHelper.filesToBase64(imageFiles);

      // Create listing with Base64 images
      final listing = Listing(
        id: '', // Will be set by repository
        title: title.trim(),
        description: description.trim(),
        category: category,
        price: price,
        condition: condition,
        city: city.trim(),
        imageUrls: imageBase64,
        sellerId: user.uid,
        sellerName: profile.displayName,
        sellerImageUrl: profile.profileImageUrl,
        status: 'active',
        createdAt: now,
        updatedAt: now,
        searchKeywords: keywords,
      );

      listingId = await _listingsRepo.createListing(listing);

      // Increment active listings count
      await ref
          .read(profileRepositoryProvider)
          .incrementActiveListings(user.uid);

      // Invalidate feed providers
      ref.invalidate(recentListingsProvider);
    });
    return state.hasError ? null : listingId;
  }

  /// Update an existing listing.
  Future<bool> updateListing({
    required String listingId,
    required String title,
    required String description,
    required ListingCategory category,
    required double price,
    required ListingCondition condition,
    required String city,
    List<String>? existingImageUrls,
    List<File>? newImageFiles,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final keywords = Listing.generateSearchKeywords(title, description);

      List<String> imageUrls = existingImageUrls ?? [];

      // Convert new images to Base64
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        final newBase64 = await ImageHelper.filesToBase64(newImageFiles);
        imageUrls.addAll(newBase64);
      }

      await _listingsRepo.updateListing(listingId, {
        'title': title.trim(),
        'description': description.trim(),
        'category': category.name,
        'price': price,
        'condition': condition.name,
        'city': city.trim(),
        'imageUrls': imageUrls,
        'searchKeywords': keywords,
      });

      ref.invalidate(recentListingsProvider);
    });

    return !state.hasError;
  }

  /// Delete a listing.
  Future<bool> deleteListing(String listingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uid = ref.read(currentUserIdProvider);
      await _listingsRepo.deleteListing(listingId);

      if (uid != null) {
        await ref.read(profileRepositoryProvider).decrementActiveListings(uid);
      }

      ref.invalidate(recentListingsProvider);
    });
    return !state.hasError;
  }

  /// Mark listing as sold (owner action, no buyer).
  Future<bool> markAsSold(String listingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uid = ref.read(currentUserIdProvider);
      await _listingsRepo.markAsSold(listingId);

      if (uid != null) {
        await ref.read(profileRepositoryProvider).decrementActiveListings(uid);
      }

      ref.invalidate(recentListingsProvider);
    });
    return !state.hasError;
  }

  /// Buy a listing: creates transaction, marks sold, credits seller balance.
  Future<String?> buyListing({
    required String listingId,
    required String sellerId,
    required String listingTitle,
    required double price,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final buyerId = ref.read(currentUserIdProvider);
      final buyerProfile = await ref.read(currentProfileProvider.future);
      if (buyerId == null || buyerProfile == null) {
        throw Exception('Not authenticated');
      }

      if (buyerProfile.balance < price) {
        throw Exception('Insufficient balance. Please top up your profile.');
      }

      final now = DateTime.now();
      final record = TransactionRecord(
        id: '',
        buyerId: buyerId,
        sellerId: sellerId,
        listingId: listingId,
        listingTitle: listingTitle,
        price: price,
        completedAt: now,
      );

      try {
        await Future.wait([
          ref.read(transactionsRepositoryProvider).createTransaction(record),
          _listingsRepo.markAsSold(listingId),
          ref.read(profileRepositoryProvider).decrementActiveListings(sellerId),
          ref.read(profileRepositoryProvider).addBalance(sellerId, price),
          ref.read(profileRepositoryProvider).addBalance(buyerId, -price),
        ]);
      } catch (e) {
        rethrow;
      }

      ref.invalidate(recentListingsProvider);
      ref.invalidate(purchaseHistoryProvider);
      ref.invalidate(salesHistoryProvider);
    });
    return state.hasError
        ? state.error.toString().replaceAll('Exception: ', '')
        : null;
  }
}

final listingsControllerProvider =
    AsyncNotifierProvider<ListingsController, void>(ListingsController.new);
