import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers.dart';
import '../../profile/providers.dart';
import '../domain/rating.dart';
import '../providers.dart';

/// Shows the rating dialog and submits the rating.
/// [toUid] – the user being rated (seller)
/// [transactionId] – used as idempotency key
/// [listingTitle] – shown for context
Future<void> showRateUserDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String toUid,
  required String transactionId,
  required String listingTitle,
}) async {
  final alreadyRated = await ref
      .read(ratingsRepositoryProvider)
      .hasRated(toUid, transactionId);

  if (alreadyRated) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already rated this transaction.')),
      );
    }
    return;
  }

  if (context.mounted) {
    await showDialog(
      context: context,
      builder: (ctx) => _RateUserDialogContent(
        ref: ref,
        toUid: toUid,
        transactionId: transactionId,
        listingTitle: listingTitle,
      ),
    );
  }
}

class _RateUserDialogContent extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String toUid;
  final String transactionId;
  final String listingTitle;

  const _RateUserDialogContent({
    required this.ref,
    required this.toUid,
    required this.transactionId,
    required this.listingTitle,
  });

  @override
  ConsumerState<_RateUserDialogContent> createState() =>
      _RateUserDialogContentState();
}

class _RateUserDialogContentState
    extends ConsumerState<_RateUserDialogContent> {
  int _stars = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final uid = ref.read(currentUserIdProvider);
    final profile = ref.read(currentProfileProvider).value;
    if (uid == null || profile == null) return;

    setState(() => _submitting = true);
    try {
      final rating = Rating(
        id: '',
        fromUid: uid,
        fromName: profile.displayName,
        toUid: widget.toUid,
        transactionId: widget.transactionId,
        listingTitle: widget.listingTitle,
        stars: _stars,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        createdAt: DateTime.now(),
      );
      await ref.read(ratingsRepositoryProvider).submitRating(rating);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: const Text('Rate the seller'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.listingTitle,
              style: AppTextStyles.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return IconButton(
                icon: Icon(
                  star <= _stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.accent,
                  size: 36,
                ),
                onPressed: () => setState(() => _stars = star),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textPrimary),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Optional comment...',
              hintStyle: AppTextStyles.bodyMedium,
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Skip'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
