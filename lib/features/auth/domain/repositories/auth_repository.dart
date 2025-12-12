import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

abstract class AuthRepository {
  Future<bool> login(String server);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
}
