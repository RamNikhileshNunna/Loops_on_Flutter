import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:loops_flutter/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:loops_flutter/features/feed/domain/models/feed_page.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';

part 'feed_controller.g.dart';

@riverpod
class FeedController extends _$FeedController {
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  FutureOr<List<VideoModel>> build() async {
    final page = await _fetchPage();
    _setCursor(page);
    return page.videos;
  }

  Future<FeedPage> _fetchPage({String? cursor}) async {
    final repository = ref.read(feedRepositoryProvider);
    return repository.getForYouFeed(cursor: cursor);
  }

  void _setCursor(FeedPage page) {
    _nextCursor = page.nextCursor;
    _hasMore = _nextCursor != null && _nextCursor!.isNotEmpty;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    final current = state.asData?.value ?? const <VideoModel>[];
    final cursor = _nextCursor;
    if (cursor == null || cursor.isEmpty) {
      _hasMore = false;
      return;
    }

    _isLoadingMore = true;
    try {
      final page = await _fetchPage(cursor: cursor);
      _setCursor(page);

      final existingIds = current.map((e) => e.id).toSet();
      final merged = <VideoModel>[
        ...current,
        ...page.videos.where((v) => !existingIds.contains(v.id)),
      ];

      state = AsyncValue.data(merged);
    } catch (e, st) {
      // Don't break the feed UI if pagination fails; keep the existing list.
      if (kDebugMode) {
        debugPrint('Feed loadMore failed: $e');
        debugPrintStack(stackTrace: st);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final page = await _fetchPage();
      _setCursor(page);
      return page.videos;
    });
  }
}
