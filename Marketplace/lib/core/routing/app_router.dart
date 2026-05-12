import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../features/auth/providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/chat/presentation/chats_list_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/listings/presentation/create_listing_screen.dart';
import '../../features/listings/presentation/edit_listing_screen.dart';
import '../../features/listings/presentation/home_screen.dart';
import '../../features/listings/presentation/listing_detail_screen.dart';
import '../../features/profile/presentation/create_profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/seller/presentation/seller_dashboard_screen.dart';
import '../../features/transactions/presentation/transaction_history_screen.dart';
import '../constants/app_colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/favorites')) return 2;
    if (location.startsWith('/chats')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go('/home');
              case 1:
                context.go('/search');
              case 2:
                context.go('/favorites');
              case 3:
                context.go('/chats');
              case 4:
                context.go('/profile');
            }
          },
          backgroundColor: AppColors.cardDark,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(
                Icons.favorite_rounded,
                color: AppColors.primary,
              ),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.primary,
              ),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final user = authState.value;
      final isLoggedIn = user != null;
      final path = state.uri.toString();

      final isAuthRoute =
          path == '/login' ||
          path == '/signup' ||
          path == '/create-profile' ||
          path == '/verify-email';

      if (!isLoggedIn && !isAuthRoute) return '/login';

      if (isLoggedIn) {
        if (path == '/login' || path == '/signup') return '/home';
        final isVerified =
            fb.FirebaseAuth.instance.currentUser?.emailVerified ?? false;
        if (!isVerified && path != '/verify-email') {
          return '/verify-email';
        }
      }

      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: '/create-profile',
        builder: (_, __) => const CreateProfileScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const VerifyEmailScreen(),
      ),

      // Main app shell
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
          GoRoute(
            path: '/favorites',
            builder: (_, __) => const FavoritesScreen(),
          ),
          GoRoute(path: '/chats', builder: (_, __) => const ChatsListScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Detail / action routes (no bottom nav)
      GoRoute(
        path: '/listing/:id',
        builder:
            (_, state) =>
                ListingDetailScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/create-listing',
        builder: (_, __) => const CreateListingScreen(),
      ),
      GoRoute(
        path: '/edit-listing/:id',
        builder:
            (_, state) =>
                EditListingScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/seller-dashboard',
        builder: (_, __) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (_, __) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder:
            (_, state) => ChatScreen(threadId: state.pathParameters['id']!),
      ),
    ],
  );
});
