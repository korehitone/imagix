import 'package:imagix/domain/collection/model/collection.dart';
import 'package:imagix/domain/follow/model/follow.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/profile/model/profile.dart';

class ProfileData {
  final bool isSuccess;
  final Profile? profile;
  final List<Collection> collections;
  final List<Follow> followers;
  final List<Follow> followings;
  final List<Post> posts;
  final String? errorMessage;

  const ProfileData({
    this.isSuccess = false,
    this.profile,
    this.collections = const [],
    this.followers = const [],
    this.followings = const [],
    this.posts = const [],
    this.errorMessage,
  });

  factory ProfileData.empty() => ProfileData();

  ProfileData copyWith({
    bool? isSuccess,
    Profile? profile,
    List<Collection>? collections,
    List<Follow>? followers,
    List<Follow>? followings,
    List<Post>? posts,
    String? errorMessage,
  }) => ProfileData(
    isSuccess: isSuccess ?? this.isSuccess,
    profile: profile ?? this.profile,
    posts: posts ?? this.posts,
    collections: collections ?? this.collections,
    followers: followers ?? this.followers,
    followings: followings ?? this.followings,
    errorMessage: errorMessage,
  );
}
