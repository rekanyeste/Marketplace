import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/firestore_paths.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Request permission and save FCM token. Safe to call on all platforms.
  Future<void> initialize(String uid) async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      // Web requires a VAPID key for getToken(); skip token storage on web
      // until a VAPID key is configured in firebase_options.
      if (kIsWeb) return;

      final token = await _messaging.getToken();
      if (token != null) await _saveToken(uid, token);

      _messaging.onTokenRefresh
          .listen((t) => _saveToken(uid, t))
          .onError((e) => debugPrint('FCM token refresh error: $e'));
    } catch (e) {
      // FCM is optional – never crash the app if it fails
      debugPrint('FCM init error: $e');
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await _db.collection(FirestorePaths.users).doc(uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('FCM token save failed: $e');
    }
  }

  Future<void> clearToken(String uid) async {
    if (kIsWeb) return;
    try {
      await _db.collection(FirestorePaths.users).doc(uid).update({
        'fcmToken': null,
      });
    } catch (e) {
      debugPrint('FCM token clear failed: $e');
    }
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService());
