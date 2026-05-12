import 'package:cloud_firestore/cloud_firestore.dart';
import 'listing_category.dart';

/// Marketplace listing model.
class Listing {
  final String id;
  final String title;
  final String description;
  final ListingCategory category;
  final double price;
  final ListingCondition condition;
  final String city;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final String? sellerImageUrl;
  final String status; // "active" or "sold"
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> searchKeywords;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.condition,
    required this.city,
    required this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    this.sellerImageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.searchKeywords,
  });

  bool get isActive => status == 'active';
  bool get isSold => status == 'sold';

  /// Generate search keywords from title and description.
  static List<String> generateSearchKeywords(String title, String description) {
    final words = <String>{};
    for (final word in title.toLowerCase().split(RegExp(r'\s+'))) {
      if (word.length >= 2) {
        words.add(word);
        // Add prefixes for prefix search
        for (int i = 2; i <= word.length; i++) {
          words.add(word.substring(0, i));
        }
      }
    }
    for (final word in description.toLowerCase().split(RegExp(r'\s+'))) {
      if (word.length >= 3) {
        words.add(word);
      }
    }
    return words.toList();
  }

  /// Create from Firestore document.
  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: ListingCategory.fromString(data['category'] ?? 'other'),
      price: (data['price'] ?? 0).toDouble(),
      condition: ListingCondition.fromString(data['condition'] ?? 'good'),
      city: data['city'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerImageUrl: data['sellerImageUrl'],
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
    );
  }

  /// Convert to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'price': price,
      'condition': condition.name,
      'city': city,
      'imageUrls': imageUrls,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerImageUrl': sellerImageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'searchKeywords': searchKeywords,
    };
  }

  /// Create a copy with some fields changed.
  Listing copyWith({
    String? id,
    String? title,
    String? description,
    ListingCategory? category,
    double? price,
    ListingCondition? condition,
    String? city,
    List<String>? imageUrls,
    String? sellerId,
    String? sellerName,
    String? sellerImageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? searchKeywords,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      city: city ?? this.city,
      imageUrls: imageUrls ?? this.imageUrls,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerImageUrl: sellerImageUrl ?? this.sellerImageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      searchKeywords: searchKeywords ?? this.searchKeywords,
    );
  }
}
