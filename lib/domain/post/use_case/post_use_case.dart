import 'package:imagix/domain/post/use_case/create_post_use_case.dart';
import 'package:imagix/domain/post/use_case/delete_post_use_case.dart';
import 'package:imagix/domain/post/use_case/get_posts_use_case.dart';
import 'package:imagix/domain/post/use_case/toggle_like_use_case.dart';
import 'package:imagix/domain/post/use_case/update_post_use_case.dart';

class PostUseCase {
  final GetPostsUseCase getPosts;
  final CreatePostUseCase create;
  final UpdatePostUseCase update;
  final DeletePostUseCase delete;
  final ToggleLikeUseCase toggleLike;

  const PostUseCase({
    required this.getPosts,
    required this.create,
    required this.update,
    required this.delete,
    required this.toggleLike,
  });
}
