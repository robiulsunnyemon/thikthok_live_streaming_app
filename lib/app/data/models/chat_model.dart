
class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isMe = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    // এখানে json['sender'] একটি Map, তাই তার ভেতর থেকে 'id' নিতে হবে
    String sId = json['sender'] is Map ? json['sender']['id'] : json['sender_id'];
    String rId = json['receiver'] is Map ? json['receiver']['id'] : json['receiver_id'];

    return ChatMessage(
      id: json['_id'] ?? '',
      senderId: sId,
      receiverId: rId,
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isMe: sId == currentUserId, // নিজের আইডি'র সাথে তুলনা করে isMe সেট করুন
    );
  }
}



