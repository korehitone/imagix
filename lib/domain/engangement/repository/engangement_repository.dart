import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/engangement/model/comment.dart';

abstract class EngangementRepository {
  Stream<ResultState<List<Comment>>> getComments(String postId);
}
