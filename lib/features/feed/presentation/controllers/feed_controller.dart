import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/feed/data/repositories/feed_repository_impl.dart';

part 'feed_controller.g.dart';

@riverpod
class FeedController extends _$FeedController {
  @override
  FutureOr<List<VideoModel>> build() async {
    return _fetchFeed();
  }

  Future<List<VideoModel>> _fetchFeed({String? cursor}) async {
    final repository = ref.read(feedRepositoryProvider);
    return repository.getForYouFeed(cursor: cursor);
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Logic to get cursor from last item or meta (simplified here)
    // Assuming the repo/API handles pagination via cursor.
    // loops-expo uses `meta.next_cursor`. Our VideoModel doesn't currently wrap the list in a response object
    // that holds the cursor. We might need to adjust Repository to return a wrapper or handle cursor state here.
    // For now, let's just re-fetch or assume infinite scroll needs adjustment.
    // Stub for now.
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchFeed());
  }
}
