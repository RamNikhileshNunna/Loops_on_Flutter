import 'package:loops_flutter/features/feed/domain/models/video_model.dart';

abstract class FeedRepository {
  Future<List<VideoModel>> getForYouFeed({String? cursor});
  Future<List<VideoModel>> getFollowingFeed({String? cursor});
}
