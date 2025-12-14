import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 46,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
              ? CachedNetworkImageProvider(user.avatar!)
              : null,
          child: (user.avatar == null || user.avatar!.isEmpty)
              ? const Icon(Icons.person, size: 46, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          '@${user.username}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Stat(label: 'Following', value: user.followingCount),
            _divider(),
            _Stat(label: 'Followers', value: user.followerCount),
            _divider(),
            _Stat(label: 'Likes', value: user.likesCount),
          ],
        ),
        if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
          height: 24,
          child: VerticalDivider(width: 1),
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _format(value),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }

  String _format(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }
}

class ProfileVideoGrid extends StatelessWidget {
  const ProfileVideoGrid({super.key, required this.videos, this.emptyText = 'No videos yet'});

  final List<VideoModel> videos;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(color: Colors.grey)),
      );
    }

    // loops.video API (for this clone) only provides a video URL (`media.src_url`).
    // We show a simple placeholder tile and open the video on tap later if needed.
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 9 / 16,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final v = videos[index];
        return _VideoTile(video: v);
      },
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video});

  final VideoModel video;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black12),
          const Center(child: Icon(Icons.play_arrow, color: Colors.white70, size: 32)),
          Positioned(
            left: 6,
            bottom: 6,
            child: Row(
              children: [
                const Icon(Icons.favorite, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${video.likes}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
