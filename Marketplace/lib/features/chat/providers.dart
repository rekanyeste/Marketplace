import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers.dart';
import 'data/chat_repository.dart';
import 'domain/chat_message.dart';
import 'domain/chat_thread.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Streams all chat threads for the current user.
final userChatsProvider = StreamProvider<List<ChatThread>>((ref) async* {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    yield [];
    return;
  }
  final repo = ref.watch(chatRepositoryProvider);
  yield* Stream.fromFuture(repo.getUserChats(uid)).asyncExpand((_) async* {
    yield await repo.getUserChats(uid);
  });
});

/// Fetches chat threads as a Future (for refresh).
final userChatsFutureProvider = FutureProvider<List<ChatThread>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Future.value([]);
  return ref.watch(chatRepositoryProvider).getUserChats(uid);
});

/// Streams messages in a specific thread.
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, threadId) {
  return ref.watch(chatRepositoryProvider).streamMessages(threadId);
});

/// Streams a single chat thread.
final chatThreadProvider =
    StreamProvider.family<ChatThread?, String>((ref, threadId) {
  return ref.watch(chatRepositoryProvider).streamThread(threadId);
});
