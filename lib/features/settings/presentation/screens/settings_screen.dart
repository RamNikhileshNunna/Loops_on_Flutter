import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../profile/presentation/controllers/profile_videos_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    await ref.read(currentUserControllerProvider.notifier).refresh();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: currentUser.when(
        data: (user) {
          final isLoggedIn = user != null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person, color: Colors.white),
                title: Text(
                  isLoggedIn ? '@${user.username}' : 'Not logged in',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  isLoggedIn ? 'Manage your account' : 'Login to manage account',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.login, color: Colors.white),
                title: Text(
                  isLoggedIn ? 'Logout' : 'Login',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  if (isLoggedIn) {
                    await _logout(context, ref);
                  } else {
                    if (context.mounted) context.go('/login');
                  }
                },
              ),
            ],
          );
        },
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}

