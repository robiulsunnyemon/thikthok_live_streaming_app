import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thikthok/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: (){
                Get.toNamed(Routes.LIVE_FEED);
              },
              child: const Text(
                'LiveStreaming',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: (){
                Get.toNamed(Routes.PROFILE);
              },
              child: const Text(
                'My Profile',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: (){
                Get.toNamed(Routes.CHAT);
              },
              child: const Text(
                'Chat',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Row()
        ],
      ),
    );
  }
}
