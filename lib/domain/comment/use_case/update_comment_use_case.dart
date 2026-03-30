import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/comment/repository/comment_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/comment_request.dart';

class UpdateCommentUseCase {
  final CommentRepository _commentRepository;
  final AuthRepository _authRepository;

  const UpdateCommentUseCase(this._commentRepository, this._authRepository);

  Future<ResultState<bool>> invoke(
    int commentId,
    CommentRequest request,
  ) async {
    if (request.comment.isEmpty) {
      return Error("Comment can not be empty.");
    }

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }

    final result = await _commentRepository.update(user.id, commentId, request);
    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "COMMENT_NOT_FOUND_OR_DENIED"
            ? "Failed to update. Comment not found or access denied."
            : key,
      ),
    };
  }
}
