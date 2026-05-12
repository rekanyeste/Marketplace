import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/listing_card.dart';
import '../../favorites/providers.dart';
import '../../profile/providers.dart';
import '../domain/listing.dart';
import '../domain/listing_category.dart';
import '../providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategory;

  // Pagination state (only used for the "recent/city" feed, not category)
  final List<Listing> _pagedListings = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _initialLoaded = false;
  DocumentSnapshot? _lastDoc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load first page after first frame (safe to call ref.read here in post-frame)
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreListings());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_selectedCategory != null) return;
    if (_isLoadingMore || !_hasMore) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreListings();
    }
  }

  void _resetFeed() {
    setState(() {
      _pagedListings.clear();
      _lastDoc = null;
      _hasMore = true;
      _initialLoaded = false;
    });
  }

  Future<void> _loadMoreListings() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final profile = ref.read(currentProfileProvider).value;
      final repo = ref.read(listingsRepositoryProvider);

      List<Listing> newItems;
      DocumentSnapshot? newLastDoc;

      if (profile?.city != null && profile!.city.isNotEmpty) {
        // City feed doesn't support cursor pagination via DocumentSnapshot easily
        // so we fall back to the standard recent listings
        final result = await repo.getRecentListingsPage(
          limit: 20,
          startAfter: _lastDoc,
        );
        newItems = result.items;
        newLastDoc = result.lastDoc;
      } else {
        final result = await repo.getRecentListingsPage(
          limit: 20,
          startAfter: _lastDoc,
        );
        newItems = result.items;
        newLastDoc = result.lastDoc;
      }

      if (mounted) {
        setState(() {
          final existingIds = _pagedListings.map((l) => l.id).toSet();
          _pagedListings.addAll(newItems.where((l) => !existingIds.contains(l.id)));
          _lastDoc = newLastDoc;
          _hasMore = newItems.length == 20;
          _initialLoaded = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;

    // For category: use existing FutureProvider
    final categoryListingsAsync = _selectedCategory != null
        ? ref.watch(categoryListingsProvider(_selectedCategory!))
        : null;

    final favoriteIds = ref.watch(favoriteIdsProvider).value ?? {};

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SafeArea(
            child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.cardDark,
          onRefresh: () async {
            if (_selectedCategory != null) {
              ref.invalidate(categoryListingsProvider(_selectedCategory!));
            } else {
              _resetFeed();
              await _loadMoreListings();
            }
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NearBuy',
                                  style: AppTextStyles.h1.copyWith(
                                    foreground: Paint()
                                      ..shader =
                                          AppColors.primaryGradient.createShader(
                                        const Rect.fromLTWH(0, 0, 200, 40),
                                      ),
                                  ),
                                ),
                                if (profile?.city != null &&
                                    profile!.city.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        profile.city,
                                        style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.divider, width: 0.5),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppColors.textSecondary,
                                  size: 22),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.push('/search'),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded,
                                  color: AppColors.textTertiary, size: 22),
                              const SizedBox(width: 12),
                              Text('Search for anything...',
                                  style: AppTextStyles.bodyMedium),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.tune_rounded,
                                    color: AppColors.primary, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Category Chips ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        CategoryChip(
                          label: 'All',
                          icon: Icons.apps_rounded,
                          isSelected: _selectedCategory == null,
                          onTap: () {
                            if (_selectedCategory != null) {
                              setState(() => _selectedCategory = null);
                              _resetFeed();
                              _loadMoreListings();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ...ListingCategory.values.map(
                          (cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              label: cat.label,
                              icon: cat.icon,
                              isSelected: _selectedCategory == cat.name,
                              onTap: () => setState(
                                () => _selectedCategory =
                                    _selectedCategory == cat.name
                                        ? null
                                        : cat.name,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Section Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      Text(
                        _selectedCategory != null
                            ? ListingCategory.fromString(_selectedCategory!)
                                .label
                            : profile?.city != null &&
                                    profile!.city.isNotEmpty
                                ? 'Near You'
                                : 'Recent Listings',
                        style: AppTextStyles.h3,
                      ),
                      const Spacer(),
                      if (_selectedCategory != null)
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = null);
                            _resetFeed();
                            _loadMoreListings();
                          },
                          child: Text('Clear',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.primary)),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Listings Grid ──
              if (_selectedCategory != null)
                categoryListingsAsync!.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(child: Text('Error: $e')),
                  ),
                  data: (listings) => _buildGrid(listings, favoriteIds),
                )
              else ...[
                if (!_initialLoaded && _isLoadingMore)
                  const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                  )
                else if (_pagedListings.isEmpty && _initialLoaded)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.storefront_outlined,
                      title: 'No listings yet',
                      subtitle: 'Be the first to sell something in your area!',
                    ),
                  )
                else
                  _buildGrid(_pagedListings, favoriteIds),
              ],

              // ── Load more indicator ──
              if (_selectedCategory == null && _isLoadingMore && _initialLoaded)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-listing'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Sell',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  SliverGrid _buildGrid(List<Listing> listings, Set<String> favoriteIds) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.gridColumns(context),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: Responsive.gridAspectRatio(context),
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final listing = listings[index];
          return ListingCard(
            listing: listing,
            isFavorited: favoriteIds.contains(listing.id),
            onTap: () => context.push('/listing/${listing.id}'),
            onFavorite: () => ref
                .read(favoritesControllerProvider.notifier)
                .toggleFavorite(listing.id),
          );
        },
        childCount: listings.length,
      ),
    );
  }
}
