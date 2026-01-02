import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thikthok/app/routes/app_pages.dart';
import '../models/live_stream_model.dart';
import 'package:thikthok/app/data/providers/chat_provider.dart'; // Reuse logic if needed or extend GetConnect

class LiveStreamProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://eron.mtscorporate.com/api/v1';

    httpClient.addRequestModifier<dynamic>((request) {
      final token = GetStorage().read('token');
      if (token == null) {
         // Optionally redirect to login, but handle gracefully
      }
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token'; 
      }
      return request;
    });
  }

  // Placeholder for fetching active lives via HTTP if available
  Future<List<LiveStreamModel>> getActiveLiveStreams() async {
    final response = await get('/live/active');
    if (response.status.hasError) {
      return [];
    } else {
      List<dynamic> data = response.body;
      return data.map((json) => LiveStreamModel.fromJson(json)).toList();
    }
  }

  Future<List<LiveStreamModel>> getUserLiveStreams({int skip = 0, int limit = 10}) async {
    final response = await get('/live/all_livestream/user?skip=$skip&limit=$limit');
    if (response.status.hasError) {
      return [];
    } else {
      List<dynamic> data = response.body;
      return data.map((json) => LiveStreamModel.fromJson(json)).toList();
    }
  }
}
