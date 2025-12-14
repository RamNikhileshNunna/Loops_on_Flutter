import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/network/api_client.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepositoryImpl(apiClient);
});

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepositoryImpl(this._apiClient);

  // Based on Loops API docs: the "self" account feed returns the user's posted videos.
  // If this still doesn't match the server, update the endpoints here.
  static const String _myVideosPath = 'api/v1/feed/account/self';
  static const String _myLikesPath = 'api/v1/account/videos/liked';

  @override
  Future<List<VideoModel>> getMyVideos({String? cursor}) async {
    final response = await _apiClient.get(
      _myVideosPath,
      queryParameters: cursor != null ? {'cursor': cursor} : null,
    );

    final data = response.data;
    final List<dynamic> items =
        (data is Map<String, dynamic> && data['data'] is List) ? data['data'] as List<dynamic> : const [];

    return items
        .whereType<Map>()
        .map((e) => VideoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<List<VideoModel>> getMyLikedVideos({String? cursor}) async {
    final response = await _apiClient.get(
      _myLikesPath,
      queryParameters: cursor != null ? {'cursor': cursor} : null,
    );

    final data = response.data;
    final List<dynamic> items =
        (data is Map<String, dynamic> && data['data'] is List) ? data['data'] as List<dynamic> : const [];

    return items
        .whereType<Map>()
        .map((e) => VideoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
