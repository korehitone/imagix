import 'package:imagix/domain/comment/use_case/create_comment_use_case.dart';
import 'package:imagix/domain/comment/use_case/delete_comment_use_case.dart';
import 'package:imagix/domain/comment/use_case/get_comments_use_case.dart';
import 'package:imagix/domain/comment/use_case/update_comment_use_case.dart';

class CommentUseCase {
  final GetCommentsUseCase getComments;
  final CreateCommentUseCase create;
  final UpdateCommentUseCase update;
  final DeleteCommentUseCase delete;

  const CommentUseCase({
    required this.getComments,
    required this.create,
    required this.update,
    required this.delete,
  });
}
