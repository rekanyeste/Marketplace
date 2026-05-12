import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers.dart';
import 'data/profile_repository.dart';
import 'domain/user_profile.dart';

/// Provides the ProfileRepository singleton.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Streams the current user's profile.
final currentProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).streamProfile(uid);
});

/// Fetches a profile by UID (one-time).
final profileByIdProvider =
    FutureProvider.family<UserProfile?, String>((ref, uid) {
  return ref.watch(profileRepositoryProvider).getProfile(uid);
});

/// Checks if the current user has a profile.
final hasProfileProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return false;
  return ref.watch(profileRepositoryProvider).profileExists(uid);
});
