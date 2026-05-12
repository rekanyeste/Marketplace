import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/ratings_repository.dart';
import 'domain/rating.dart';

final ratingsRepositoryProvider = Provider<RatingsRepository>((ref) {
  return RatingsRepository();
});

final userRatingsProvider =
    FutureProvider.family<List<Rating>, String>((ref, uid) {
  return ref.watch(ratingsRepositoryProvider).getRatings(uid);
});
