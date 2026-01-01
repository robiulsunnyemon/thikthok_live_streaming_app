import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthProvider authProvider = AuthProvider();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize provider explicitly if not injected via binding dependency
    authProvider.onInit(); 
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter both email and password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Basic email validation
    if (!GetUtils.isEmail(email)) {
       Get.snackbar(
        "Error",
        "Please enter a valid email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }


    isLoading.value = true;
    try {
      final response = await authProvider.login(email, password);
      
      isLoading.value = false;

      if (response.statusCode == 200) {

        final body = response.body;
        print(response.body);
        if (body != null && body is Map && body['access_token'] != null) {
          final token = body['access_token'];
          GetStorage().write('token', token);
          print("Token: $token");
        }

        Get.snackbar(
          "Success",
          "Login Successful!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate to dashboard or home
        Get.offAllNamed(Routes.HOME);
      } else {
         String errorMessage = "Login failed";
         if(response.body != null && response.body is Map && response.body['message'] != null){
           errorMessage = response.body['message'];
         }

        Get.snackbar(
          "Login Failed",
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
