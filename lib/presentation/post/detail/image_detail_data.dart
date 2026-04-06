import 'package:imagix/domain/collection/model/collection.dart';
import 'package:imagix/domain/comment/model/comment.dart';
import 'package:imagix/domain/post/model/post.dart';

class ImageDetailData {
  final bool isSuccess;
  final bool isDeleted;
  final String? errorMessage;
  final String? userId;
  final int? replyingToId; // ID bapak yang mau di-reply
  final String? replyingToName;
  final Post? post;
  final List<Comment> comments;
  final List<Collection> collections;

  const ImageDetailData({
    this.isSuccess = false,
    this.isDeleted = false,
    this.errorMessage,
    this.post,
    this.replyingToId,
    this.replyingToName,
    this.userId,
    this.comments = const [],
    this.collections = const [],
  });

  factory ImageDetailData.empty() => ImageDetailData();

  ImageDetailData copyWith({
    bool? isSuccess,
    bool? isDeleted,
    String? userId,
    int? replyingToId,
    String? replyingToName,
    Post? post,
    String? errorMessage,
    List<Comment>? comments,
    List<Collection>? collections,
  }) => ImageDetailData(
    isSuccess: isSuccess ?? this.isSuccess,
    isDeleted: isDeleted ?? this.isDeleted,
    userId: userId ?? this.userId,
    replyingToId: replyingToId,
    replyingToName: replyingToName,
    post: post ?? this.post,
    comments: comments ?? this.comments,
    collections: collections ?? this.collections,
    errorMessage: errorMessage,
  );
}
