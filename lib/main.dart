import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'features/feed/presentation/screens/feed_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/explore/presentation/screens/explore_screen.dart';
import 'features/activity/presentation/screens/activity_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    if (location.startsWith('/explore')) {
      currentIndex = 1;
    } else if (location.startsWith('/activity')) {
      currentIndex = 2;
    } else if (location.startsWith('/profile')) {
      currentIndex = 3;
    }
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/explore');
              break;
            case 2:
              context.go('/activity');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(StorageService(prefs)),
      ],
      child: const LoopsApp(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final authRepo = ref.read(authRepositoryProvider);
      final isAuthenticated = await authRepo.isAuthenticated();
      final isLoginPage = state.matchedLocation == '/login';
      
      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoginPage) {
        return '/login';
      }
      
      // If authenticated and on login page, redirect to home
      if (isAuthenticated && isLoginPage) {
        return '/';
      }
      
      return null; // No redirect needed
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const FeedScreen()),
          GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
          GoRoute(path: '/activity', builder: (context, state) => const ActivityScreen()),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ],
  );
});

class LoopsApp extends ConsumerWidget {
  const LoopsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Loops Expo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force dark for now
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
