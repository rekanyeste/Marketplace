import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers.dart';
import 'data/transactions_repository.dart';
import 'domain/transaction_record.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository();
});

final salesHistoryProvider = FutureProvider<List<TransactionRecord>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Future.value([]);
  return ref.watch(transactionsRepositoryProvider).getSalesHistory(uid);
});

final purchaseHistoryProvider = FutureProvider<List<TransactionRecord>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Future.value([]);
  return ref.watch(transactionsRepositoryProvider).getPurchaseHistory(uid);
});
