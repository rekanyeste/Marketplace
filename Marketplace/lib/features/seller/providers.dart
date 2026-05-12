import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers.dart';
import '../listings/providers.dart';

// Seller dashboard providers are re-exported from listings providers.
// sellerActiveListingsProvider and sellerSoldListingsProvider
// are already defined in listings/providers.dart.

/// Provider for the current user's active listing count.
final myActiveListingsProvider = FutureProvider((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Future.value([]);
  return ref.watch(sellerActiveListingsProvider(uid).future);
});

/// Provider for the current user's sold listing count.
final mySoldListingsProvider = FutureProvider((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Future.value([]);
  return ref.watch(sellerSoldListingsProvider(uid).future);
});
