import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers.dart';

class NearBuyApp extends ConsumerWidget {
  const NearBuyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Initialize FCM whenever a user signs in
    ref.listen<AsyncValue>(authStateProvider, (_, next) {
      final uid = next.value?.uid;
      if (uid != null) {
        ref.read(fcmServiceProvider).initialize(uid);
      }
    });

    return MaterialApp.router(
      title: 'NearBuy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
