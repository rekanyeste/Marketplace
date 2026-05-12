import 'package:flutter/material.dart';

/// Product listing categories.
enum ListingCategory {
  electronics('Electronics', Icons.devices_rounded),
  fashion('Fashion', Icons.checkroom_rounded),
  home('Home', Icons.home_rounded),
  books('Books', Icons.menu_book_rounded),
  sports('Sports', Icons.sports_soccer_rounded),
  vehicles('Vehicles', Icons.directions_car_rounded),
  other('Other', Icons.category_rounded);

  final String label;
  final IconData icon;

  const ListingCategory(this.label, this.icon);

  /// Convert string to enum.
  static ListingCategory fromString(String value) {
    return ListingCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ListingCategory.other,
    );
  }
}

/// Product condition options.
enum ListingCondition {
  brandNew('New'),
  likeNew('Like New'),
  good('Good'),
  fair('Fair');

  final String label;

  const ListingCondition(this.label);

  static ListingCondition fromString(String value) {
    return ListingCondition.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ListingCondition.good,
    );
  }
}
