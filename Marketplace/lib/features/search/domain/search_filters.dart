// Search filter model — uses string category names for simplicity.

/// Search filter model.
class SearchFilters {
  final String keyword;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String? city;
  final String sortBy; // 'newest', 'price_low', 'price_high'

  const SearchFilters({
    this.keyword = '',
    this.category,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.city,
    this.sortBy = 'newest',
  });

  SearchFilters copyWith({
    String? keyword,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? city,
    String? sortBy,
    bool clearCategory = false,
    bool clearCondition = false,
    bool clearCity = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return SearchFilters(
      keyword: keyword ?? this.keyword,
      category: clearCategory ? null : (category ?? this.category),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      condition: clearCondition ? null : (condition ?? this.condition),
      city: clearCity ? null : (city ?? this.city),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters =>
      category != null ||
      minPrice != null ||
      maxPrice != null ||
      condition != null ||
      city != null ||
      sortBy != 'newest';

  SearchFilters clearAll() => SearchFilters(keyword: keyword);
}
