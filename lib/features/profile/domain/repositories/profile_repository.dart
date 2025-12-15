import 'package:loops_flutter/features/feed/domain/models/feed_page.dart';

abstract class ProfileRepository {
  Future<FeedPage> getMyVideos({String? cursor});
  Future<FeedPage> getMyLikedVideos({String? cursor});
}
