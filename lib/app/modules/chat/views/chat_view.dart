import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';


class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Active Users List
          Container(
            height: 110,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey[100],
            child: Obx(() {
              if (controller.isLoadingUsers.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.activeUsers.isEmpty) {
                return const Center(child: Text('No active users'));
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.activeUsers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final user = controller.activeUsers[index];
                  return GestureDetector(
                    onTap: () => controller.selectUser(user),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(user.profileImage),
                              onBackgroundImageError: (_, __) {
                                // Fallback icon or image
                              },
                              child: user.profileImage.isEmpty 
                                ? const Icon(Icons.person) 
                                : null,
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.fullName.split(' ').first,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          
          Expanded(
            child: Obx(() {
              if (controller.selectedUser.value == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Select a user to start chatting'),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Chat Header for Selected User
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey[200],
                    child: Row(
                      children: [
                        Text(
                          'Chatting with ${controller.selectedUser.value!.fullName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  
                  // Messages List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final msg = controller.messages[index];
                        return Align(
                          alignment: msg.isMe 
                              ? Alignment.centerRight 
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: msg.isMe 
                                  ? Colors.blue 
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              msg.message,
                              style: TextStyle(
                                color: msg.isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Input Area
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: controller.sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
