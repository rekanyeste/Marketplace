import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../domain/listing.dart';

/// Repository for listing CRUD with Firestore.
class ListingsRepository {
  final FirebaseFirestore _db;

  ListingsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference get _listingsRef =>
      _db.collection(FirestorePaths.listings);

  /// Create a new listing.
  Future<String> createListing(Listing listing) async {
    final doc = _listingsRef.doc();
    final data = listing.copyWith(id: doc.id).toFirestore();
    await doc.set(data);
    return doc.id;
  }

  /// Get a single listing by ID.
  Future<Listing?> getListing(String id) async {
    final doc = await _listingsRef.doc(id).get();
    if (!doc.exists) return null;
    return Listing.fromFirestore(doc);
  }

  /// Stream a single listing.
  Stream<Listing?> streamListing(String id) {
    return _listingsRef.doc(id).snapshots().map(
          (doc) => doc.exists ? Listing.fromFirestore(doc) : null,
        );
  }

  /// Update listing fields.
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _listingsRef.doc(id).update(data);
  }

  /// Delete a listing.
  Future<void> deleteListing(String id) async {
    await _listingsRef.doc(id).delete();
  }

  /// Mark listing as sold.
  Future<void> markAsSold(String id) async {
    await _listingsRef.doc(id).update({
      'status': 'sold',
      'updatedAt': Timestamp.now(),
    });
  }

  /// Fetch recent active listings with cursor-based pagination.
  Future<List<Listing>> getRecentListings({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _listingsRef
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    return snap.docs.map((d) => Listing.fromFirestore(d)).toList();
  }

  /// Fetch recent listings and return both items and last document for pagination.
  Future<({List<Listing> items, DocumentSnapshot? lastDoc})>
      getRecentListingsPage({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _listingsRef
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    final items = snap.docs.map((d) => Listing.fromFirestore(d)).toList();
    final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
    return (items: items, lastDoc: lastDoc);
  }

  /// Fetch listings by city (for location-aware browsing).
  Future<List<Listing>> getListingsByCity({
    required String city,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _listingsRef
        .where('status', isEqualTo: 'active')
        .where('city', isEqualTo: city)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    return snap.docs.map((d) => Listing.fromFirestore(d)).toList();
  }

  /// Fetch listings by category.
  Future<List<Listing>> getListingsByCategory({
    required String category,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _listingsRef
        .where('status', isEqualTo: 'active')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    return snap.docs.map((d) => Listing.fromFirestore(d)).toList();
  }

  /// Fetch listings by seller.
  Future<List<Listing>> getListingsBySeller({
    required String sellerId,
    String? statusFilter,
  }) async {
    Query query = _listingsRef.where('sellerId', isEqualTo: sellerId);

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter);
    }

    query = query.orderBy('createdAt', descending: true);

    final snap = await query.get();
    return snap.docs.map((d) => Listing.fromFirestore(d)).toList();
  }

  /// Search listings with keyword matching.
  Future<List<Listing>> searchListings({
    required String keyword,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? city,
    String sortBy = 'newest',
    int limit = 30,
  }) async {
    Query query = _listingsRef.where('status', isEqualTo: 'active');

    // Keyword search using array-contains
    if (keyword.isNotEmpty) {
      query = query.where(
        'searchKeywords',
        arrayContains: keyword.toLowerCase().trim(),
      );
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }

    if (condition != null) {
      query = query.where('condition', isEqualTo: condition);
    }

    // Sort
    switch (sortBy) {
      case 'price_low':
        query = query.orderBy('price', descending: false);
        break;
      case 'price_high':
        query = query.orderBy('price', descending: true);
        break;
      default:
        query = query.orderBy('createdAt', descending: true);
    }

    query = query.limit(limit);

    final snap = await query.get();
    var results = snap.docs.map((d) => Listing.fromFirestore(d)).toList();

    // Client-side price filtering (Firestore limitation with compound queries)
    if (minPrice != null) {
      results = results.where((l) => l.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      results = results.where((l) => l.price <= maxPrice).toList();
    }

    return results;
  }

  /// Get similar listings (same category, different ID).
  Future<List<Listing>> getSimilarListings({
    required String category,
    required String excludeId,
    String? city,
    int limit = 6,
  }) async {
    Query query = _listingsRef
        .where('status', isEqualTo: 'active')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(limit + 1);

    if (city != null) {
      query = _listingsRef
          .where('status', isEqualTo: 'active')
          .where('category', isEqualTo: category)
          .where('city', isEqualTo: city)
          .orderBy('createdAt', descending: true)
          .limit(limit + 1);
    }

    final snap = await query.get();
    return snap.docs
        .map((d) => Listing.fromFirestore(d))
        .where((l) => l.id != excludeId)
        .take(limit)
        .toList();
  }
}
