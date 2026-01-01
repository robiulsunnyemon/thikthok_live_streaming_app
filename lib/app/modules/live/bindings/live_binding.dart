import 'package:get/get.dart';
import '../controllers/live_controller.dart';
import '../../../data/services/live_socket_service.dart';
import '../../../data/providers/live_stream_provider.dart';

class LiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveSocketService>(() => LiveSocketService());
    Get.lazyPut<LiveStreamProvider>(() => LiveStreamProvider());
    Get.lazyPut<LiveController>(() => LiveController());
  }
}
