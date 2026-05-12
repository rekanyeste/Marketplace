import 'package:cloud_firestore/cloud_firestore.dart';

/// Favorite reference stored in user subcollection.
class Favorite {
  final String listingId;
  final DateTime addedAt;

  const Favorite({required this.listingId, required this.addedAt});

  factory Favorite.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Favorite(
      listingId: doc.id,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'listingId': listingId,
    'addedAt': Timestamp.fromDate(addedAt),
  };
}
