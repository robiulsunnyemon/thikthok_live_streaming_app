

import 'live_stream_model.dart';

class LiveCommentModel {
  final LiveStreamUser user;
  final String message;

  LiveCommentModel({
    required this.user,
    required this.message,
  });

  factory LiveCommentModel.fromJson(Map<String, dynamic> json) {
    return LiveCommentModel(
      user: LiveStreamUser.fromJson(json['user'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}
