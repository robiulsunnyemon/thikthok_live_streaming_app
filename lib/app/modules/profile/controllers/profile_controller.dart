import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/profile_provider.dart';

class ProfileController extends GetxController {
  final ProfileProvider provider = Get.find<ProfileProvider>();
  
  final isLoading = true.obs;
  final user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final result = await provider.getMyProfile();
      if (result != null) {
        user.value = result;
      }
    } catch (e) {
      print("Profile Error: $e");
      Get.snackbar("Error", "Failed to load profile");
    } finally {
      isLoading.value = false;
    }
  }
}
