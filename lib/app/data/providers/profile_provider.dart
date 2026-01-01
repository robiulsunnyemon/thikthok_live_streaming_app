import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class ProfileProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://eron.mtscorporate.com/api/v1';
    
    // Add token to requests
    httpClient.addRequestModifier<dynamic>((request) {
      final token = GetStorage().read('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });
  }

  Future<UserModel?> getMyProfile() async {
    final response = await get('/users/users/my_profile');
    if (response.status.hasError) {
      print("Error getting profile: ${response.statusText}");
      return null;
    } else {
      return UserModel.fromJson(response.body);
    }
  }
}
