import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thikthok/app/routes/app_pages.dart';
import '../models/active_user.dart';
import '../models/chat_model.dart';


class ChatProvider extends GetConnect {
  ChatProvider() {
    httpClient.baseUrl = 'https://eron.mtscorporate.com/api/v1';

    // Add request modifier to inject token
    httpClient.addRequestModifier<dynamic>((request) {
      final token = GetStorage().read('token');
      if (token == null) {
        Get.toNamed(Routes.LOGIN); // Assuming Bearer token
      }
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token'; // Assuming Bearer token
      }
      return request;
    });
  }

  Future<List<ActiveUser>> getActiveUsers() async {
    final response = await get('/chat/active-users');
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Error fetching users');
    } else {
      List<dynamic> data = response.body;
      return data.map((json) => ActiveUser.fromJson(json)).toList();
    }
  }

  Future<List<ChatMessage>> getChatHistory(String otherUserId, String currentUserId) async {
    final response = await get('/chat/history/$otherUserId');
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Error fetching history');
    } else {
      List<dynamic> data = response.body;
      return data.map((json) => ChatMessage.fromJson(json, currentUserId)).toList();
    } 
  }
  
  // Helper to get profile for ID
  Future<ActiveUser?> getMyProfile() async {
    final response = await get('/users/users/my_profile');
    if (response.status.hasError) {
       return null;
    } else {
       // Assuming response body is UserModel structure. ActiveUser requires specific fields.
       // Mapping UserModel to ActiveUser temporarily for ID or returning a lightweight object.
       // Actually I just need the ID.
       final data = response.body; 
       return ActiveUser(
         userId: data['_id'],
         fullName: "${data['first_name']} ${data['last_name']}",
         profileImage: data['profile_image'] ?? '',
         isFollowing: false
       );
    }
  }
}
