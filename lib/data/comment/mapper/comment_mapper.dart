import '../../../domain/comment/model/comment.dart';

class CommentMapper {
  static List<Comment> toNested(List<Comment> flatComments) {
    // 1. Ambil semua komentar utama (yang parent_id nya null)
    final List<Comment> rootComments = flatComments
        .where((comment) => comment.parentId == null)
        .toList();

    // 2. Ambil semua balasan (yang punya parent_id)
    final List<Comment> allReplies = flatComments
        .where((comment) => comment.parentId != null)
        .toList();

    // 3. Masukkan setiap balasan ke dalam 'replies' milik bapaknya yang cocok
    return rootComments.map((root) {
      final relatedReplies = allReplies
          .where((reply) => reply.parentId == root.id)
          .toList();
      return root.copyWith(replies: relatedReplies);
    }).toList();
  }
}
