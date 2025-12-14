import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:loops_flutter/core/network/api_client.dart';
import 'package:loops_flutter/core/storage/storage_service.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(apiClient, storage);
});

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storage;

  bool _needs2fa = false;

  AuthRepositoryImpl(this._apiClient, this._storage);

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!await isAuthenticated()) return null;

    try {
      final response = await _apiClient.get('api/v1/account/info/self');
      if (response.statusCode != 200) {
        await _storage.setLoggedIn(false);
        return null;
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = (data['data'] is Map<String, dynamic>) ? data['data'] as Map<String, dynamic> : data;
        return UserModel.fromJson(payload);
      }

      return null;
    } catch (_) {
      await _storage.setLoggedIn(false);
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _storage.getLoggedIn();
  }

  @override
  Future<bool> login({
    required String email,
    required String password,
    String? captchaType,
    String? captchaToken,
  }) async {
    // Force official server for now.
    await _storage.setInstance('loops.video');

    _needs2fa = false;

    // Sanctum CSRF cookie + session login.
    await _apiClient.ensureCsrfCookie();

    var res = await _apiClient.post(
      'login',
      data: {
        'email': email,
        'password': password,
        'remember': true,
        if (captchaType != null) 'captcha_type': captchaType,
        if (captchaToken != null) 'captcha_token': captchaToken,
      },
    );

    // Common Sanctum failure if XSRF cookie rotated.
    if (res.statusCode == 419) {
      await _apiClient.ensureCsrfCookie();
      res = await _apiClient.post(
        'login',
        data: {
          'email': email,
          'password': password,
          'remember': true,
          if (captchaType != null) 'captcha_type': captchaType,
          if (captchaToken != null) 'captcha_token': captchaToken,
        },
      );
    }

    if (res.statusCode == 200 || res.statusCode == 204) {
      if (res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        _needs2fa = map['has_2fa'] == true;
      }

      if (_needs2fa) {
        // Don’t mark logged in yet.
        return false;
      }

      await _storage.setLoggedIn(true);
      return true;
    }

    // Surface useful server error information.
    if (res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      throw Exception(map['message'] ?? map.toString());
    }
    throw Exception('Login failed (${res.statusCode})');
  }

  @override
  Future<bool> submitTwoFactor({required String otpCode}) async {
    if (!_needs2fa) return false;

    final res = await _apiClient.post(
      'api/v1/auth/2fa/verify',
      data: {'otp_code': otpCode},
    );

    if (res.statusCode == 200) {
      _needs2fa = false;
      await _storage.setLoggedIn(true);
      return true;
    }

    if (res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      throw Exception(map['message'] ?? map.toString());
    }
    throw Exception('2FA verify failed (${res.statusCode})');
  }

  @override
  Future<void> logout() async {
    await _storage.clearToken();
    await _storage.setLoggedIn(false);
    // Note: cookies are in-memory; restarting app clears them.
  }
}
