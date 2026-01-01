import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/live/bindings/live_binding.dart';
import '../modules/live/views/live_feed_view.dart';
import '../modules/live/views/start_live_view.dart';
import '../modules/live/views/live_stream_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();
  static final token = GetStorage().read('token');


  static final INITIAL =token!=null?Routes.HOME:Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.LIVE_FEED,
      page: () => const LiveFeedView(),
      binding: LiveBinding(),
    ),
    GetPage(
      name: _Paths.START_LIVE,
      page: () => const StartLiveView(),
      binding: LiveBinding(),
    ),
    GetPage(
      name: _Paths.LIVE_STREAM,
      page: () => const LiveStreamView(),
      binding: LiveBinding(),
    ),
  ];
}
