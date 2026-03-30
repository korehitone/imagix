import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/comment/repository/comment_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/comment.dart';

class GetCommentsUseCase {
  final CommentRepository _commentRepository;
  final AuthRepository _authRepository;

  const GetCommentsUseCase(this._commentRepository, this._authRepository);

  Future<ResultState<List<Comment>>> invoke(String postId) async {
    if (_authRepository.getCurrentUser() == null) {
      return const Error("Please login to view comments.");
    }

    return _commentRepository.getComments(postId);
  }
}
