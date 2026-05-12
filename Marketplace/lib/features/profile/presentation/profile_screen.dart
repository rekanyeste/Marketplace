import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/presentation/auth_controller.dart';
import '../providers.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/edit-profile'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Profile not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/create-profile'),
                    child: const Text('Create Profile'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed:
                        () =>
                            ref.read(authControllerProvider.notifier).signOut(),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surfaceDark,
                      child:
                          profile.profileImageUrl != null
                              ? ClipOval(
                                child: CachedImage(
                                  imageUrl: profile.profileImageUrl,
                                  width: 100,
                                  height: 100,
                                ),
                              )
                              : Text(
                                profile.displayName.isNotEmpty
                                    ? profile.displayName[0].toUpperCase()
                                    : '?',
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                    ),
                    const SizedBox(height: 16),
                    Text(profile.displayName, style: AppTextStyles.h2),
                    const SizedBox(height: 4),
                    Text(profile.email, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 24),
                    // Stats row
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            label: 'Listings',
                            value: '${profile.activeListings}',
                            icon: Icons.sell_outlined,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.divider,
                          ),
                          _StatItem(
                            label: 'Rating',
                            value:
                                profile.rating > 0
                                    ? '${profile.rating.toStringAsFixed(1)} ★'
                                    : 'N/A',
                            icon: Icons.star_outline_rounded,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.divider,
                          ),
                          Stack(
                            alignment: Alignment.topRight,
                            clipBehavior: Clip.none,
                            children: [
                              _StatItem(
                                label: 'Balance',
                                value: PriceFormatter.format(profile.balance),
                                icon: Icons.account_balance_wallet_outlined,
                              ),
                              Positioned(
                                right: -20,
                                top: -12,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    ref
                                        .read(
                                          profileControllerProvider.notifier,
                                        )
                                        .updateProfile(
                                          balance: profile.balance + 10000,
                                        );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Info items
                    _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: profile.city,
                    ),
                    const SizedBox(height: 32),
                    // Menu items
                    _MenuTile(
                      icon: Icons.dashboard_outlined,
                      label: 'Seller Dashboard',
                      onTap: () => context.push('/seller-dashboard'),
                    ),
                    _MenuTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'Transaction History',
                      onTap: () => context.push('/transactions'),
                    ),
                    _MenuTile(
                      icon: Icons.favorite_border_rounded,
                      label: 'Saved Items',
                      onTap: () => context.push('/favorites'),
                    ),
                    const SizedBox(height: 24),
                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .signOut();
                        },
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.error,
                        ),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size(double.infinity, 52),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.textSecondary),
          title: Text(label, style: AppTextStyles.bodyLarge),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),
    );
  }
}
