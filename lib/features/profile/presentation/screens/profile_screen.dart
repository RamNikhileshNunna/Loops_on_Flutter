import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/profile_content_controllers.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserState = ref.watch(currentUserControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(currentUserControllerProvider.notifier).refresh();
              ref.read(myVideosControllerProvider.notifier).refresh();
              ref.read(myLikedVideosControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: currentUserState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Login'),
              ),
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                ProfileHeader(user: user),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('Settings'),
                    ),
                  ),
                ),
                const Divider(height: 1),
                const TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(text: 'Videos'),
                    Tab(text: 'Likes'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _VideosTab(userId: user.id),
                      const _LikesTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _VideosTab extends ConsumerWidget {
  const _VideosTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myVideosControllerProvider);

    return state.when(
      data: (videos) => ProfileVideoGrid(
        videos: videos,
        emptyText: 'No videos posted yet',
        isMyVideos: true,
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Failed to load your videos.\n\n$err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _LikesTab extends ConsumerWidget {
  const _LikesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myLikedVideosControllerProvider);

    return state.when(
      data: (videos) => ProfileVideoGrid(
        videos: videos,
        emptyText: 'No liked videos yet',
        isMyVideos: false,
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Failed to load liked videos.\n\n$err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
