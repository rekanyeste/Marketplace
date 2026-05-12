import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../domain/user_profile.dart';

/// Repository for user profile CRUD in Firestore.
class ProfileRepository {
  final FirebaseFirestore _db;

  ProfileRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Create a new user profile.
  Future<void> createProfile(UserProfile profile) async {
    await _db
        .collection(FirestorePaths.users)
        .doc(profile.uid)
        .set(profile.toFirestore());
  }

  /// Get a user profile by UID.
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection(FirestorePaths.users).doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Stream a user profile.
  Stream<UserProfile?> streamProfile(String uid) {
    return _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  /// Update profile fields.
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection(FirestorePaths.users).doc(uid).update(data);
  }

  /// Check if profile exists.
  Future<bool> profileExists(String uid) async {
    final doc = await _db.collection(FirestorePaths.users).doc(uid).get();
    return doc.exists;
  }

  /// Increment active listings count.
  Future<void> incrementActiveListings(String uid) async {
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'activeListings': FieldValue.increment(1),
    });
  }

  /// Decrement active listings count.
  Future<void> decrementActiveListings(String uid) async {
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'activeListings': FieldValue.increment(-1),
    });
  }

  /// Add amount to user's balance.
  Future<void> addBalance(String uid, double amount) async {
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'balance': FieldValue.increment(amount),
    });
  }

  /// Update seller rating after a new review.
  Future<void> updateRating(String uid, double newAverage, int newCount) async {
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'rating': newAverage,
      'ratingCount': newCount,
    });
  }
}
