import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/repositories/video_actions_repository.dart';

final videoActionsRepositoryProvider = Provider<VideoActionsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VideoActionsRepositoryImpl(apiClient);
});

class VideoActionsRepositoryImpl implements VideoActionsRepository {
  final ApiClient _apiClient;

  VideoActionsRepositoryImpl(this._apiClient);

  @override
  Future<bool> likeVideo(String videoId) async {
    try {
      final response = await _apiClient.post(
        'api/v1/videos/$videoId/like',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> unlikeVideo(String videoId) async {
    try {
      final response = await _apiClient.post(
        'api/v1/videos/$videoId/unlike',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> commentVideo(String videoId, String comment) async {
    try {
      final response = await _apiClient.post(
        'api/v1/videos/$videoId/comments',
        data: {'comment': comment},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteComment(String videoId, String commentId) async {
    try {
      await _apiClient.post(
        'api/v1/videos/$videoId/comments/$commentId/delete',
      );
    } catch (e) {
      // Ignore errors for delete
    }
  }
}

