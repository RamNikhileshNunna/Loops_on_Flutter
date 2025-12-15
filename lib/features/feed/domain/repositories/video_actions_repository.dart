abstract class VideoActionsRepository {
  Future<bool> likeVideo(String videoId);
  Future<bool> unlikeVideo(String videoId);
  Future<bool> commentVideo(String videoId, String comment);
  Future<void> deleteComment(String videoId, String commentId);
}

