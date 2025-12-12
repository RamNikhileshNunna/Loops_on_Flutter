import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/profile_controller.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {}, // Go to settings
          ),
        ],
      ),
      body: profileState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.push('/login');
                },
                child: const Text('Login'),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                if (user.avatar != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: CachedNetworkImageProvider(user.avatar!),
                  ),
                const SizedBox(height: 10),
                Text(
                  '@${user.username}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user.followerCount} Followers • ${user.followingCount} Following',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                // Tab Bar placeholder
                DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.black,
                        tabs: [
                          Tab(text: 'Videos'),
                          Tab(text: 'Likes'),
                          Tab(text: 'Saved'),
                        ],
                      ),
                      SizedBox(
                        height: 500, // Fixed height for now
                        child: TabBarView(
                          children: [
                            Center(child: Text('Videos Grid Placeholder')),
                            Center(child: Text('Likes Grid Placeholder')),
                            Center(child: Text('Saved Grid Placeholder')),
                          ],
                        ),
                      ),
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
