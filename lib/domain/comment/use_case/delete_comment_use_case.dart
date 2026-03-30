import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/comment/repository/comment_repository.dart';

import '../../../core/network/result_state.dart';

class DeleteCommentUseCase {
  final CommentRepository _commentRepository;
  final AuthRepository _authRepository;

  const DeleteCommentUseCase(this._commentRepository, this._authRepository);

  Future<ResultState<bool>> invoke(int commentId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }
    final result = await _commentRepository.delete(user.id, commentId);
    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "COMMENT_NOT_FOUND_OR_DENIED"
            ? "Failed to delete. Access denied."
            : key,
      ),
    };
  }
}
