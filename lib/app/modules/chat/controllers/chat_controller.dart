import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/active_user.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/services/socket_service.dart';
import '../../../data/providers/chat_provider.dart';

class ChatController extends GetxController {
  final ChatProvider provider = ChatProvider();
  final SocketService socketService = Get.put(SocketService());

  final activeUsers = <ActiveUser>[].obs;
  final messages = <ChatMessage>[].obs;
  final isLoadingUsers = true.obs;
  String currentUserId = ''; 
  
  // Selected user to chat with
  final selectedUser = Rxn<ActiveUser>();
  
  final messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchActiveUsers();
    fetchMyProfile();
    
    // Listen to incoming messages
    ever(socketService.incomingMessages, (String message) {
       if (message.isNotEmpty && selectedUser.value != null) {
         try {
           final data = jsonDecode(message);
           // Incoming: { "sender_id": ..., "message": ..., "timestamp": ... }
           final senderId = data['sender_id'];
           final currentChatId = selectedUser.value!.userId;

           if (senderId == currentChatId) {
              final newMessage = ChatMessage(
                id: data['_id'] ?? 'socket_${DateTime.now().millisecondsSinceEpoch}',
                senderId: senderId,
                receiverId: currentUserId,
                message: data['message'],
                timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
                isMe: false,
              );
              messages.add(newMessage);
           }
         } catch(e){
           print("Error parsing message: $e");
         }
       }
    });
  }

  Future<void> fetchMyProfile() async {
    try {
      final profile = await provider.getMyProfile();
      if (profile != null) {
        currentUserId = profile.userId; 
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> fetchActiveUsers() async {
    isLoadingUsers.value = true;
    try {
      final users = await provider.getActiveUsers();
      activeUsers.assignAll(users);
    } catch (e) {
      print(e.toString());
      Get.snackbar('Error', 'Failed to load active users: $e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  void selectUser(ActiveUser user) async {
    selectedUser.value = user;
    messages.clear();
    
    // Fetch History
    try {
      if (currentUserId.isNotEmpty) {
        final history = await provider.getChatHistory(user.userId, currentUserId);
        messages.assignAll(history);
      } else {
        await fetchMyProfile();
         if (currentUserId.isNotEmpty) {
            final history = await provider.getChatHistory(user.userId, currentUserId);
            messages.assignAll(history);
         }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load history");
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || selectedUser.value == null) return;

    final receiverId = selectedUser.value!.userId;
    
    final msgObj = {
      "receiver_id": receiverId, 
      "message": text
    };


    print("msgObj: $msgObj");
    print("called 1");

    socketService.sendMessage(jsonEncode(msgObj));
    print("called 2");

    // Optimistic UI update
    messages.add(ChatMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUserId, 
      receiverId: receiverId,
      message: text,
      timestamp: DateTime.now(),
      isMe: true,
    ));

    messageController.clear();
  }
  
  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
