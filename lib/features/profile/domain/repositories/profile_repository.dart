import 'package:loops_flutter/features/feed/domain/models/video_model.dart';

abstract class ProfileRepository {
  Future<List<VideoModel>> getMyVideos({String? cursor});
  Future<List<VideoModel>> getMyLikedVideos({String? cursor});
}
