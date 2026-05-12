import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';

class ChatRepository {
  final FirebaseFirestore _db;

  ChatRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Create or get existing chat thread between buyer & seller for a listing.
  Future<String> createChatThread({
    required String buyerId,
    required String sellerId,
    required String listingId,
    required String listingTitle,
  }) async {
    final existing = await _db
        .collection(FirestorePaths.chats)
        .where('buyerId', isEqualTo: buyerId)
        .where('sellerId', isEqualTo: sellerId)
        .where('listingId', isEqualTo: listingId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return existing.docs.first.id;

    final doc = _db.collection(FirestorePaths.chats).doc();
    final thread = ChatThread(
      id: doc.id,
      buyerId: buyerId,
      sellerId: sellerId,
      listingId: listingId,
      listingTitle: listingTitle,
      createdAt: DateTime.now(),
      readBy: [buyerId, sellerId],
    );
    await doc.set(thread.toFirestore());
    return doc.id;
  }

  /// Stream all chat threads for a user (as buyer or seller).
  Stream<List<ChatThread>> streamUserChats(String uid) {
    final buyerStream = _db
        .collection(FirestorePaths.chats)
        .where('buyerId', isEqualTo: uid)
        .snapshots();
    final sellerStream = _db
        .collection(FirestorePaths.chats)
        .where('sellerId', isEqualTo: uid)
        .snapshots();

    // Merge both streams manually via StreamController
    return _mergeThreadStreams(uid, buyerStream, sellerStream);
  }

  Stream<List<ChatThread>> _mergeThreadStreams(
    String uid,
    Stream<QuerySnapshot> buyerStream,
    Stream<QuerySnapshot> sellerStream,
  ) async* {
    final Map<String, ChatThread> threads = {};
    await for (final snap in buyerStream) {
      for (final doc in snap.docs) {
        threads[doc.id] = ChatThread.fromFirestore(doc);
      }
      yield threads.values.toList()
        ..sort((a, b) {
          final aTime = a.lastMessageAt ?? a.createdAt;
          final bTime = b.lastMessageAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        });
    }
  }

  /// Fetch chat threads for a user (Future, both roles).
  Future<List<ChatThread>> getUserChats(String uid) async {
    final buyerChats = await _db
        .collection(FirestorePaths.chats)
        .where('buyerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    final sellerChats = await _db
        .collection(FirestorePaths.chats)
        .where('sellerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    final Map<String, ChatThread> all = {};
    for (final doc in buyerChats.docs) {
      all[doc.id] = ChatThread.fromFirestore(doc);
    }
    for (final doc in sellerChats.docs) {
      all[doc.id] = ChatThread.fromFirestore(doc);
    }
    return all.values.toList()
      ..sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
  }

  /// Stream messages in a chat thread.
  Stream<List<ChatMessage>> streamMessages(String threadId) {
    return _db
        .collection(FirestorePaths.chatMessages(threadId))
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromFirestore(d)).toList());
  }

  /// Send a message in a thread.
  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String text,
  }) async {
    final msgRef = _db
        .collection(FirestorePaths.chatMessages(threadId))
        .doc();

    final message = ChatMessage(
      id: msgRef.id,
      senderId: senderId,
      text: text.trim(),
      sentAt: DateTime.now(),
    );

    await Future.wait([
      msgRef.set(message.toFirestore()),
      _db.collection(FirestorePaths.chats).doc(threadId).update({
        'lastMessage': text.trim(),
        'lastMessageAt': Timestamp.fromDate(message.sentAt),
        'readBy': [senderId],
      }),
    ]);
  }

  /// Mark thread as read for a specific user.
  Future<void> markThreadAsRead(String threadId, String uid) async {
    await _db.collection(FirestorePaths.chats).doc(threadId).update({
      'readBy': FieldValue.arrayUnion([uid]),
    });
  }

  /// Get a single thread.
  Future<ChatThread?> getThread(String threadId) async {
    final doc =
        await _db.collection(FirestorePaths.chats).doc(threadId).get();
    if (!doc.exists) return null;
    return ChatThread.fromFirestore(doc);
  }

  /// Stream a single thread.
  Stream<ChatThread?> streamThread(String threadId) {
    return _db
        .collection(FirestorePaths.chats)
        .doc(threadId)
        .snapshots()
        .map((doc) => doc.exists ? ChatThread.fromFirestore(doc) : null);
  }
}
