import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat thread metadata model.
class ChatThread {
  final String id;
  final String buyerId;
  final String sellerId;
  final String listingId;
  final String listingTitle;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final List<String> readBy;

  const ChatThread({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.listingId,
    required this.listingTitle,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    this.readBy = const [],
  });

  factory ChatThread.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatThread(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      listingId: data['listingId'] ?? '',
      listingTitle: data['listingTitle'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: data['lastMessage'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'buyerId': buyerId,
    'sellerId': sellerId,
    'listingId': listingId,
    'listingTitle': listingTitle,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
    'readBy': readBy,
  };
}
