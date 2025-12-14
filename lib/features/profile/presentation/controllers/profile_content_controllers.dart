import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:loops_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:loops_flutter/features/feed/domain/models/video_model.dart';
import 'package:loops_flutter/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

part 'profile_content_controllers.g.dart';

@riverpod
class CurrentUserController extends _$CurrentUserController {
  @override
  FutureOr<UserModel?> build() async {
    final authRepo = ref.read(authRepositoryProvider);
    return authRepo.getCurrentUser();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      return authRepo.getCurrentUser();
    });
  }
}

@riverpod
class MyVideosController extends _$MyVideosController {
  @override
  FutureOr<List<VideoModel>> build() async {
    final repo = ref.read(profileRepositoryProvider);
    return repo.getMyVideos();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      return repo.getMyVideos();
    });
  }
}

@riverpod
class MyLikedVideosController extends _$MyLikedVideosController {
  @override
  FutureOr<List<VideoModel>> build() async {
    final repo = ref.read(profileRepositoryProvider);
    return repo.getMyLikedVideos();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      return repo.getMyLikedVideos();
    });
  }
}
