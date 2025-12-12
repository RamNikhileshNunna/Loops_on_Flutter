import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/video_model.dart';
import '../../domain/repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedRepositoryImpl(apiClient);
});

class FeedRepositoryImpl implements FeedRepository {
  final ApiClient _apiClient;

  FeedRepositoryImpl(this._apiClient);

  @override
  Future<List<VideoModel>> getForYouFeed({String? cursor}) async {
    final response = await _apiClient.get(
      'api/v1/feed/for-you',
      queryParameters: cursor != null ? {'cursor': cursor} : null,
    );

    // Assuming response.data['data'] is the list of videos
    // Adapt based on actual API response structure
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => VideoModel.fromJson(json)).toList();
  }

  @override
  Future<List<VideoModel>> getFollowingFeed({String? cursor}) async {
    final response = await _apiClient.get(
      'api/v1/feed/following',
      queryParameters: cursor != null ? {'cursor': cursor} : null,
    );

    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => VideoModel.fromJson(json)).toList();
  }
}
