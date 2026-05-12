import 'package:cloud_firestore/cloud_firestore.dart';

/// Transaction record created when a listing is marked as sold.
class TransactionRecord {
  final String id;
  final String buyerId;
  final String sellerId;
  final String listingId;
  final String listingTitle;
  final double price;
  final DateTime completedAt;

  const TransactionRecord({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.listingId,
    required this.listingTitle,
    required this.price,
    required this.completedAt,
  });

  factory TransactionRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionRecord(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      listingId: data['listingId'] ?? '',
      listingTitle: data['listingTitle'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'buyerId': buyerId,
    'sellerId': sellerId,
    'listingId': listingId,
    'listingTitle': listingTitle,
    'price': price,
    'completedAt': Timestamp.fromDate(completedAt),
  };
}
