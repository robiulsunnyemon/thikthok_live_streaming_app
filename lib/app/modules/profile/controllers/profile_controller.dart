import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/live_stream_model.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/providers/live_stream_provider.dart';

class ProfileController extends GetxController {
  final ProfileProvider profileProvider = Get.find<ProfileProvider>();
  final LiveStreamProvider liveStreamProvider = Get.put(LiveStreamProvider());
  
  final isLoading = true.obs;
  final user = Rxn<UserModel>();
  final pastStreams = <LiveStreamModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchPastStreams();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final result = await profileProvider.getMyProfile();
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

  Future<void> fetchPastStreams() async {
    try {
      final streams = await liveStreamProvider.getUserLiveStreams();
      pastStreams.assignAll(streams);
    } catch (e) {
      print("Past Streams Error: $e");
    }
  }
}
