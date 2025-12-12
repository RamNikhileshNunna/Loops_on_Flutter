import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});

class ApiClient {
  final StorageService _storage;
  final Dio _dio;

  ApiClient(this._storage)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  String _getBaseUrl() {
    final instance = _storage.getInstance();
    if (instance == null || instance.isEmpty) {
      // Default or throw? For now default to a known instance or throw.
      // loops-expo source doesn't seem to have a hardcoded default, it asks user?
      // We will assume the user has set it or we provide a default for testing.
      return 'https://loops.video';
    }
    return 'https://$instance';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final baseUrl = _getBaseUrl();
    final headers = await _getHeaders();

    return _dio.get(
      '$baseUrl/$path',
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    final baseUrl = _getBaseUrl();
    final headers = await _getHeaders();

    return _dio.post(
      '$baseUrl/$path',
      data: data,
      options: Options(headers: headers),
    );
  }
}
