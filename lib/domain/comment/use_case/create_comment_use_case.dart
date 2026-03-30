import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/comment/repository/comment_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/comment_request.dart';

class CreateCommentUseCase {
  final CommentRepository _commentRepository;
  final AuthRepository _authRepository;

  const CreateCommentUseCase(this._commentRepository, this._authRepository);

  Future<ResultState<bool>> invoke(CommentRequest request) async {
    if (request.comment.isEmpty) {
      return Error("Comment can not be empty.");
    }

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }

    final result = await _commentRepository.create(user.id, request);
    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "COMMENT_CREATE_FAILED" ? "Failed to post comment." : key,
      ),
    };
  }
}
