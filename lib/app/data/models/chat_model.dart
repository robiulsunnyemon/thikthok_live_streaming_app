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

class ChatMessage {
  final String senderId;
  final String message;
  final bool isMe; // Helper for UI

  ChatMessage({
    required this.senderId,
    required this.message,
    this.isMe = false, 
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'message': message,
    };
  }
  
  // Add fromJson if receiving similar structure
}
