

class LiveStreamModel {
  final String id;
  final LiveStreamUser host;
  final String agoraChannelName;
  final bool isPremium;
  final double entryFee;
  final String status;
  final int totalViews;
  final int totalLikes;
  final int totalComments;

  LiveStreamModel({
    required this.id,
    required this.host,
    required this.agoraChannelName,
    this.isPremium = false,
    this.entryFee = 0.0,
    required this.status,
    this.totalViews = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      id: json['id']?.toString() ?? '',
      host: LiveStreamUser.fromJson(json['host'] ?? {}),
      agoraChannelName: json['channel_name'] ?? '',
      isPremium: json['is_premium'] ?? false,
      entryFee: (json['entry_fee'] ?? 0).toDouble(),
      status: json['status'] ?? 'live',
      totalViews: json['total_views'] ?? 0,
      totalLikes: json['total_like'] ?? 0, 
      totalComments: json['total_comment'] ?? 0, 
    );
  }
}

class LiveStreamUser {
  final String userId;
  final String fullName;
  final String profileImage;

  LiveStreamUser({
    required this.userId,
    required this.fullName,
    required this.profileImage,
  });

  factory LiveStreamUser.fromJson(Map<String, dynamic> json) {
    return LiveStreamUser(
      userId: (json['id'] ?? '').toString(),
      fullName: json['name'] ?? 'Unknown',
      profileImage: json['avatar'] ?? '',
    );
  }
}