import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';

import '../controllers/feed_controller.dart';
import '../widgets/video_player_widget.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Ensure feed loads on first entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedControllerProvider.notifier).refresh();
      ref.read(followingFeedControllerProvider.notifier).refresh();
    });
    _tabController.addListener(() {
      setState(() {});
      // Trigger load for following feed when switched the first time
      if (_tabController.index == 1) {
        final following = ref.read(followingFeedControllerProvider);
        if (following.hasError || following.isLoading || following.value?.isNotEmpty == true) return;
        ref.read(followingFeedControllerProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fullscreen immersive like TikTok
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final isForYou = _tabController.index == 0;
    final feedState = isForYou
        ? ref.watch(feedControllerProvider)
        : ref.watch(followingFeedControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: feedState.when(
        data: (videos) => _buildFeedBody(context, videos, isForYou),
        error: (err, stack) => Center(
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

  Widget _buildFeedBody(BuildContext context, List videos, bool isForYou) {
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
      onRefresh: () async {
        if (isForYou) {
          await ref.read(feedControllerProvider.notifier).refresh();
        } else {
          await ref.read(followingFeedControllerProvider.notifier).refresh();
        }
      },
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);

              // Pre-fetch next page a couple items before the end.
              if (index >= videos.length - 3) {
                if (isForYou) {
                  ref.read(feedControllerProvider.notifier).loadMore();
                } else {
                  ref.read(followingFeedControllerProvider.notifier).loadMore();
                }
              }
            },
            itemBuilder: (context, index) {
              return VideoPlayerWidget(
                video: videos[index],
                isActive: index == _currentIndex,
              );
            },
          ),
          // Floating tab toggle
          Positioned(
            top: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  tabs: const [
                    Tab(text: 'For You'),
                    Tab(text: 'Following'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
