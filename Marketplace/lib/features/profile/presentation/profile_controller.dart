import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';
import '../providers.dart';
import '../../auth/providers.dart';

/// Controller for profile creation and updates.
class ProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  /// Create profile after registration.
  Future<bool> createProfile({
    required String displayName,
    required String city,
    String? profileImageUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Not authenticated');

      final profile = UserProfile(
        uid: user.uid,
        displayName: displayName.trim(),
        email: user.email ?? '',
        profileImageUrl: profileImageUrl,
        city: city.trim(),
        joinedAt: DateTime.now(),
      );
      await _repo.createProfile(profile);
    });
    return !state.hasError;
  }

  /// Update profile fields.
  Future<bool> updateProfile({
    String? displayName,
    String? city,
    String? profileImageUrl,
    double? balance,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('Not authenticated');

      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName.trim();
      if (city != null) updates['city'] = city.trim();
      if (profileImageUrl != null) {
        updates['profileImageUrl'] = profileImageUrl;
      }
      if (balance != null) {
        updates['balance'] = balance;
      }

      if (updates.isNotEmpty) {
        await _repo.updateProfile(uid, updates);
      }
    });
    return !state.hasError;
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);
