import 'package:get/get.dart';

class AuthProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://eron.mtscorporate.com/api/v1';
    httpClient.timeout = const Duration(seconds: 30);
  }

  Future<Response> login(String email, String password) {
    final body = {
      "username": email,
      "password": password,
    };
    return post('/auth/login', body, contentType: "application/x-www-form-urlencoded");
  }
}
