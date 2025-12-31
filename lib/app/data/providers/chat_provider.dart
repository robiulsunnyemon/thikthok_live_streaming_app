import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thikthok/app/routes/app_pages.dart';
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
}
