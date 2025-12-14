import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});

class ApiClient {
  final StorageService _storage;
  final Dio _dio;
  final CookieJar _cookieJar;

  ApiClient(this._storage)
      : _cookieJar = CookieJar(),
        _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            followRedirects: true,
            // Let us inspect 4xx responses cleanly.
            validateStatus: (code) => code != null && code >= 200 && code < 500,
          ),
        ) {
    _dio.interceptors.add(CookieManager(_cookieJar));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    // Attach Sanctum XSRF header if present.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final cookies = await _cookieJar.loadForRequest(options.uri);
          Cookie? xsrf;
          for (final c in cookies) {
            if (c.name == 'XSRF-TOKEN') {
              xsrf = c;
              break;
            }
          }
          if (xsrf != null) {
            options.headers['X-XSRF-TOKEN'] = Uri.decodeComponent(xsrf.value);
          }
          handler.next(options);
        },
      ),
    );
  }

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
    final base = _getBaseUrl();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      // Sanctum commonly expects origin/referer for SPA-like flows.
      'Origin': base,
      'Referer': '$base/',
      'User-Agent': 'LoopsFlutter/0.1 (Flutter; Dio)',
      // Keep bearer support for other instances (if you later implement OAuth).
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  bool _isAbsolute(String s) => s.startsWith('http://') || s.startsWith('https://');

  Future<void> ensureCsrfCookie() async {
    final baseUrl = _getBaseUrl();
    await _dio.get(
      '$baseUrl/sanctum/csrf-cookie',
      options: Options(headers: await _getHeaders()),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final baseUrl = _getBaseUrl();
    final headers = await _getHeaders();

    final url = _isAbsolute(path) ? path : '$baseUrl/$path';
    return _dio.get(
      url,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    final baseUrl = _getBaseUrl();
    final headers = await _getHeaders();

    final url = _isAbsolute(path) ? path : '$baseUrl/$path';
    return _dio.post(
      url,
      data: data,
      options: Options(headers: headers),
    );
  }
}
