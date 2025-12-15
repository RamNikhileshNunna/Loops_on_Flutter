import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_client.dart';

final videoUploadRepositoryProvider = Provider<VideoUploadRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VideoUploadRepository(apiClient);
});

class VideoUploadRepository {
  VideoUploadRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Uploads a video file to loops.video. Returns true if server accepts it.
  Future<bool> uploadVideo({
    required XFile file,
    String? caption,
    void Function(int sent, int total)? onProgress,
  }) async {
    final form = FormData.fromMap({
      'caption': caption ?? '',
      'video': await MultipartFile.fromFile(
        file.path,
        filename: file.name,
        contentType: MediaType('video', _detectSubtype(file.path)),
      ),
    });

    try {
      await _apiClient.ensureCsrfCookie();
      final res = await _apiClient.post(
        'api/v1/videos',
        data: form,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          onSendProgress: onProgress,
        ),
      );
      return res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300;
    } catch (_) {
      return false;
    }
  }

  String _detectSubtype(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.mp4')) return 'mp4';
    if (ext.endsWith('.mov')) return 'quicktime';
    if (ext.endsWith('.mkv')) return 'x-matroska';
    if (ext.endsWith('.avi')) return 'x-msvideo';
    return 'mp4';
  }
}

