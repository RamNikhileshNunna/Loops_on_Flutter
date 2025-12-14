import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

// ignore_for_file: invalid_annotation_target

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
abstract class VideoModel with _$VideoModel {
  const factory VideoModel({
    required String id,
    required MediaModel media,
    required UserModel account,
    @Default(0) int likes,
    @Default(false) @JsonKey(name: 'has_liked') bool hasLiked,
    @Default(0) int comments,
    @Default(0) int shares,
    String? caption,
    @Default([]) List<String> tags,
    // Mentions can be added later if structure is complex
    VideoPermissions? permissions,
    VideoMeta? meta,
    @Default(false) @JsonKey(name: 'is_sensitive') bool isSensitive,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);
}

@freezed
abstract class MediaModel with _$MediaModel {
  const factory MediaModel({
    @JsonKey(name: 'src_url') required String srcUrl,
    @JsonKey(name: 'alt_text') String? altText,
  }) = _MediaModel;

  factory MediaModel.fromJson(Map<String, dynamic> json) =>
      _$MediaModelFromJson(json);
}

@freezed
abstract class VideoPermissions with _$VideoPermissions {
  const factory VideoPermissions({
    @Default(true) @JsonKey(name: 'can_comment') bool canComment,
  }) = _VideoPermissions;

  factory VideoPermissions.fromJson(Map<String, dynamic> json) =>
      _$VideoPermissionsFromJson(json);
}

@freezed
abstract class VideoMeta with _$VideoMeta {
  const factory VideoMeta({
    @Default(false) @JsonKey(name: 'contains_ai') bool containsAi,
    @Default(false) @JsonKey(name: 'contains_ad') bool containsAd,
  }) = _VideoMeta;

  factory VideoMeta.fromJson(Map<String, dynamic> json) =>
      _$VideoMetaFromJson(json);
}
