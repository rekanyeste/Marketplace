import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../listings/domain/listing.dart';
import '../listings/providers.dart';
import 'domain/search_filters.dart';

/// Current search filters state — using Notifier for Riverpod 3.x.
class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();

  void updateFilters(SearchFilters filters) {
    state = filters;
  }

  void updateKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
  }

  void clearFilters() {
    state = state.clearAll();
  }
}

final searchFiltersProvider =
    NotifierProvider<SearchFiltersNotifier, SearchFilters>(
      SearchFiltersNotifier.new,
    );

/// Search results based on current filters.
final searchResultsProvider = FutureProvider<List<Listing>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  if (filters.keyword.isEmpty && !filters.hasActiveFilters) return [];

  return ref
      .watch(listingsRepositoryProvider)
      .searchListings(
        keyword: filters.keyword,
        category: filters.category,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        condition: filters.condition,
        city: filters.city,
        sortBy: filters.sortBy,
      );
});

/// Recent searches stored locally.
final recentSearchesProvider = FutureProvider<List<String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('recent_searches') ?? [];
});

/// Save a search to recent searches.
Future<void> saveRecentSearch(String query) async {
  if (query.trim().isEmpty) return;
  final prefs = await SharedPreferences.getInstance();
  final searches = prefs.getStringList('recent_searches') ?? [];
  searches.remove(query);
  searches.insert(0, query);
  if (searches.length > 10) searches.removeLast();
  await prefs.setStringList('recent_searches', searches);
}

/// Clear all recent searches.
Future<void> clearRecentSearches() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('recent_searches');
}
