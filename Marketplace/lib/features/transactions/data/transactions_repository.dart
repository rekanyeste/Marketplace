import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../domain/transaction_record.dart';

/// Repository for transaction records.
class TransactionsRepository {
  final FirebaseFirestore _db;

  TransactionsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Create a transaction record.
  Future<String> createTransaction(TransactionRecord record) async {
    final doc = _db.collection(FirestorePaths.transactions).doc();
    await doc.set(record.toFirestore());
    return doc.id;
  }

  /// Get transactions where user is seller.
  Future<List<TransactionRecord>> getSalesHistory(String uid) async {
    final snap = await _db
        .collection(FirestorePaths.transactions)
        .where('sellerId', isEqualTo: uid)
        .orderBy('completedAt', descending: true)
        .get();
    return snap.docs.map((d) => TransactionRecord.fromFirestore(d)).toList();
  }

  /// Get transactions where user is buyer.
  Future<List<TransactionRecord>> getPurchaseHistory(String uid) async {
    final snap = await _db
        .collection(FirestorePaths.transactions)
        .where('buyerId', isEqualTo: uid)
        .orderBy('completedAt', descending: true)
        .get();
    return snap.docs.map((d) => TransactionRecord.fromFirestore(d)).toList();
  }
}
