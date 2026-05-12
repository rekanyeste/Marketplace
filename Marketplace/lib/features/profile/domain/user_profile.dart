import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model stored in Firestore.
class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? profileImageUrl;
  final String city;
  final DateTime joinedAt;
  final double rating;
  final int ratingCount;
  final int activeListings;
  final double balance;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.profileImageUrl,
    required this.city,
    required this.joinedAt,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.activeListings = 0,
    this.balance = 0.0,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      city: data['city'] ?? '',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingCount: (data['ratingCount'] ?? 0).toInt(),
      activeListings: (data['activeListings'] ?? 0).toInt(),
      balance: (data['balance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'city': city,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'rating': rating,
      'ratingCount': ratingCount,
      'activeListings': activeListings,
      'balance': balance,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? profileImageUrl,
    String? city,
    DateTime? joinedAt,
    double? rating,
    int? ratingCount,
    int? activeListings,
    double? balance,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      city: city ?? this.city,
      joinedAt: joinedAt ?? this.joinedAt,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      activeListings: activeListings ?? this.activeListings,
      balance: balance ?? this.balance,
    );
  }
}
