/// Firestore collection and document path constants.
class FirestorePaths {
  FirestorePaths._();

  // ── Collections ───────────────────────────────────────────────
  static const String users = 'users';
  static const String listings = 'listings';
  static const String chats = 'chats';
  static const String transactions = 'transactions';

  // ── Subcollections ────────────────────────────────────────────
  static String userFavorites(String uid) => 'users/$uid/favorites';
  static String userRatings(String uid) => 'users/$uid/ratings';
  static String chatMessages(String chatId) => 'chats/$chatId/messages';

  // ── Documents ─────────────────────────────────────────────────
  static String user(String uid) => 'users/$uid';
  static String listing(String id) => 'listings/$id';
  static String chat(String id) => 'chats/$id';
  static String transaction(String id) => 'transactions/$id';
  static String favorite(String uid, String listingId) =>
      'users/$uid/favorites/$listingId';
  static String rating(String uid, String ratingId) =>
      'users/$uid/ratings/$ratingId';
}
