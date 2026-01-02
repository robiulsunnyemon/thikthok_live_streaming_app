class ActiveUser {
  final String userId;
  final String fullName;
  final String profileImage;
  final bool isFollowing;

  ActiveUser({
    required this.userId,
    required this.fullName,
    required this.profileImage,
    required this.isFollowing,
  });

  factory ActiveUser.fromJson(Map<String, dynamic> json) {
    return ActiveUser(
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? 'Unknown',
      profileImage: json['profile_image'] ?? '',
      isFollowing: json['is_following'] ?? false,
    );
  }
}