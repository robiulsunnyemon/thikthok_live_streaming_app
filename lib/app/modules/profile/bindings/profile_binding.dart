import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../data/providers/profile_provider.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileProvider>(() => ProfileProvider());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
