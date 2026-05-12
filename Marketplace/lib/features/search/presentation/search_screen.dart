import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/listing_card.dart';
import '../../favorites/providers.dart';
import '../providers.dart';
import 'widgets/filter_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    ref.read(searchFiltersProvider.notifier).updateKeyword(query);
    if (query.isNotEmpty) {
      saveRecentSearch(query);
      ref.invalidate(recentSearchesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFiltersProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final recentAsync = ref.watch(recentSearchesProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider).value ?? {};
    final hasQuery = filters.keyword.isNotEmpty || filters.hasActiveFilters;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search marketplace...',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                      : null,
            ),
              onSubmitted: _performSearch,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() {}),
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed:
                    () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const FilterBottomSheet(),
                    ),
              ),
              if (filters.hasActiveFilters)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: hasQuery
              ? resultsAsync.when(
                loading:
                    () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (results) {
                  if (results.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No results found',
                      subtitle: 'Try different keywords or adjust your filters',
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: Responsive.gridColumns(context),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: Responsive.gridAspectRatio(context),
                        ),
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final listing = results[i];
                      return ListingCard(
                        listing: listing,
                        isFavorited: favoriteIds.contains(listing.id),
                        onTap: () => context.push('/listing/${listing.id}'),
                        onFavorite:
                            () => ref
                                .read(favoritesControllerProvider.notifier)
                                .toggleFavorite(listing.id),
                      );
                    },
                  );
                },
              )
              : // Recent searches
              recentAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (recent) {
                  if (recent.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_rounded,
                      title: 'Start searching',
                      subtitle: 'Find great deals near you',
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Text('Recent Searches', style: AppTextStyles.h3),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              await clearRecentSearches();
                              ref.invalidate(recentSearchesProvider);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      ...recent.map(
                        (s) => ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: AppColors.textTertiary,
                          ),
                          title: Text(s, style: AppTextStyles.bodyLarge),
                          onTap: () {
                            _searchController.text = s;
                            _performSearch(s);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              ),
    ),
    );
  }
}
