import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String fromUid;
  final String fromName;
  final String toUid;
  final String transactionId;
  final String listingTitle;
  final int stars;
  final String? comment;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.transactionId,
    required this.listingTitle,
    required this.stars,
    this.comment,
    required this.createdAt,
  });

  factory Rating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rating(
      id: doc.id,
      fromUid: data['fromUid'] ?? '',
      fromName: data['fromName'] ?? '',
      toUid: data['toUid'] ?? '',
      transactionId: data['transactionId'] ?? '',
      listingTitle: data['listingTitle'] ?? '',
      stars: (data['stars'] ?? 5).toInt(),
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'fromUid': fromUid,
    'fromName': fromName,
    'toUid': toUid,
    'transactionId': transactionId,
    'listingTitle': listingTitle,
    'stars': stars,
    'comment': comment,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
