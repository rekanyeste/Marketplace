import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/providers.dart';
import '../providers.dart';
import '../domain/chat_thread.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsFutureProvider);
    final currentUid = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: chatsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (chats) {
          if (chats.isEmpty) {
            return const EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No conversations yet',
              subtitle: 'Contact a seller from a listing to start chatting',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(userChatsFutureProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.divider, indent: 72),
              itemBuilder: (_, i) => _ChatTile(
                thread: chats[i],
                currentUid: currentUid ?? '',
              ),
            ),
          );
        },
      ),
      ),
    ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatThread thread;
  final String currentUid;

  const _ChatTile({required this.thread, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    final time = thread.lastMessageAt ?? thread.createdAt;
    final isBuyer = thread.buyerId == currentUid;
    final otherRole = isBuyer ? 'Seller' : 'Buyer';
    final isUnread = !thread.readBy.contains(currentUid);

    return InkWell(
      onTap: () => context.push('/chat/${thread.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.listingTitle,
                          style: AppTextStyles.bodyLarge
                              .copyWith(fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Text(
                        timeago.format(time),
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
                          color: isUnread ? AppColors.primary : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    otherRole,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary),
                  ),
                  if (thread.lastMessage != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      thread.lastMessage!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                        color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
