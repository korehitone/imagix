import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/post/model/post.dart';

abstract class PostRepository {
  Stream<ResultState<List<Post>>> getFeeds();
}
