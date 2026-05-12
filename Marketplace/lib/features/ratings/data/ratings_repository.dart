import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../profile/data/profile_repository.dart';
import '../domain/rating.dart';

class RatingsRepository {
  final FirebaseFirestore _db;

  RatingsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Submit a rating for a user. Recalculates their average rating.
  Future<void> submitRating(Rating rating) async {
    final ratingRef = _db
        .collection(FirestorePaths.userRatings(rating.toUid))
        .doc(rating.transactionId);

    // Prevent duplicate ratings for the same transaction
    final existing = await ratingRef.get();
    if (existing.exists) return;

    await ratingRef.set(rating.toFirestore());

    // Recalculate average
    final allRatings = await _db
        .collection(FirestorePaths.userRatings(rating.toUid))
        .get();

    final stars =
        allRatings.docs.map((d) => (d.data()['stars'] as num).toInt()).toList();
    final avg = stars.isEmpty
        ? 0.0
        : stars.reduce((a, b) => a + b) / stars.length;

    await ProfileRepository(db: _db)
        .updateRating(rating.toUid, avg, stars.length);
  }

  /// Check if a rating already exists for a transaction.
  Future<bool> hasRated(String toUid, String transactionId) async {
    final doc = await _db
        .collection(FirestorePaths.userRatings(toUid))
        .doc(transactionId)
        .get();
    return doc.exists;
  }

  /// Fetch all ratings for a user.
  Future<List<Rating>> getRatings(String uid) async {
    final snap = await _db
        .collection(FirestorePaths.userRatings(uid))
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Rating.fromFirestore(d)).toList();
  }
}
