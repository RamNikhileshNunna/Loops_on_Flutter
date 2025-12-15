import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/presentation/controllers/feed_controller.dart';
import '../../../feed/domain/models/video_model.dart';
import 'explore_viewer_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedControllerProvider.notifier).refresh();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(feedControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final feedState = ref.watch(feedControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Explore', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(feedControllerProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: feedState.when(
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(
              child: Text(
                'No videos found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return RefreshIndicator(
            backgroundColor: Colors.black,
            color: Colors.white,
            onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 9 / 14, // Taller cells like Instagram explore
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return _ExploreTile(
                  video: video,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExploreViewerScreen(
                          initialIndex: index,
                          videos: videos,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({required this.video, required this.onTap});

  final VideoModel video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumb = video.media.thumbnailUrl ?? video.media.srcUrl;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: thumb,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.black26,
                child: const Icon(Icons.play_arrow, color: Colors.white70, size: 36),
              ),
            ),
            Positioned(
              bottom: 6,
              left: 6,
              right: 6,
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${video.likes}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.play_circle_fill, color: Colors.white, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

