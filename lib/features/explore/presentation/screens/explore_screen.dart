import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/presentation/controllers/feed_controller.dart';
import '../../../feed/presentation/widgets/video_player_widget.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final feedState = ref.watch(feedControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: feedState.when(
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(
              child: Text(
                'No videos found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return RefreshIndicator(
            backgroundColor: Colors.black,
            color: Colors.white,
            onRefresh: () =>
                ref.read(feedControllerProvider.notifier).refresh(),
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);

                if (index >= videos.length - 3) {
                  ref.read(feedControllerProvider.notifier).loadMore();
                }
              },
              itemBuilder: (context, index) {
                return VideoPlayerWidget(
                  video: videos[index],
                  isActive: index == _currentIndex,
                );
              },
            ),
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

