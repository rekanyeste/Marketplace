import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../domain/favorite.dart';

/// Repository for favorites CRUD using Firestore subcollections.
class FavoritesRepository {
  final FirebaseFirestore _db;

  FavoritesRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference _favRef(String uid) =>
      _db.collection(FirestorePaths.userFavorites(uid));

  /// Add a listing to favorites.
  Future<void> addFavorite(String uid, String listingId) async {
    await _favRef(uid).doc(listingId).set(
      Favorite(listingId: listingId, addedAt: DateTime.now()).toFirestore(),
    );
  }

  /// Remove a listing from favorites.
  Future<void> removeFavorite(String uid, String listingId) async {
    await _favRef(uid).doc(listingId).delete();
  }

  /// Check if a listing is favorited.
  Future<bool> isFavorited(String uid, String listingId) async {
    final doc = await _favRef(uid).doc(listingId).get();
    return doc.exists;
  }

  /// Get all favorite IDs for a user.
  Stream<Set<String>> streamFavoriteIds(String uid) {
    return _favRef(uid).snapshots().map(
      (snap) => snap.docs.map((d) => d.id).toSet(),
    );
  }

  /// Get all favorites.
  Future<List<Favorite>> getFavorites(String uid) async {
    final snap = await _favRef(uid).orderBy('addedAt', descending: true).get();
    return snap.docs.map((d) => Favorite.fromFirestore(d)).toList();
  }
}
