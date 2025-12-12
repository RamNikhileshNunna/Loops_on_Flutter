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

  AuthRepositoryImpl(this._apiClient, this._storage);

  @override
  Future<UserModel?> getCurrentUser() async {
    // In a real app, we might fetch from DB or decoding the token if it has info,
    // or fetch from API if we have a token.
    // loops-expo stores user profile in storage.
    // For now, let's try to fetch self if we have a token.
    if (!await isAuthenticated()) return null;

    try {
      final response = await _apiClient.get('api/v1/account/info/self');
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      // If fetch fails (token expired?), clean up or return null
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _storage.getToken() != null;
  }

  @override
  Future<bool> login(String server) async {
    // 1. Preflight check
    try {
      final nodeInfo = await _apiClient.get('https://$server/nodeinfo/2.1');
      // Note: ApiClient adds base URL, we might need a raw request or override base URL
      // Actually ApiClient computes base URL from storage, but we are *logging in* so we might not have it set yet.
      // We should probably use a raw Dio call or update ApiClient to accept a base URL override.

      // ... Validation logic ...

      // 2. Register App
      // 3. OAuth Flow

      // For this replica, we'll stub this to fail or simulate success if we mock.
      // Saving specific server instance first
      await _storage.setInstance(server);
      return true; // Placeholder
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await _storage.clearToken();
    // await _storage.clearInstance(); // Optional, maybe keep instance
  }
}
