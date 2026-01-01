import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../controllers/live_controller.dart';
import '../../../data/models/live_comment_model.dart';

class LiveStreamView extends GetView<LiveController> {
  const LiveStreamView({super.key});

  @override
  Widget build(BuildContext context) {
    // Arguments handling if needed
    final args = Get.arguments as Map<String, dynamic>?;
    final isHostArg = args?['isHost'] ?? false;
    final channelArg = args?['channel'];
    
    // If we came from Join (Live Feed), call join.
    // If we came from Start (Start View), we might have already called startLive or call it here.
    // Ideally controller handles life cycle. StartView already called startLive? 
    // Let's ensure connection.
    if (!isHostArg && channelArg != null) {
      if (controller.currentChannel.value != channelArg) {
        controller.joinLive(channelArg);
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Agora Video Layer
          Obx(() {
            if (!controller.isJoined.value && !controller.isEngineInitialized.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.isHost.value) {
               // Local Preview
               return AgoraVideoView(
                 controller: VideoViewController(
                   rtcEngine: controller.engine, 
                   canvas: const VideoCanvas(uid: 0),
                 ),
               );
            } else {
              // Remote View
              if (controller.remoteUid.value == 0) {
                return const Center(child: Text("Waiting for host...", style: TextStyle(color: Colors.white)));
              }
              return AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: controller.engine,
                  canvas: VideoCanvas(uid: controller.remoteUid.value),
                  connection: RtcConnection(channelId: controller.currentChannel.value),
                ),
              );
            }
          }),

          // 2. Gradient Overlay for readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.6, 1.0],
              ),
            ),
          ),

          // 3. UI Controls
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Obx(() => Text("${controller.viewerCount.value}", style: const TextStyle(color: Colors.white))),
                          ],
                        ),
                      ),

                      
                      // COIN DISPLAY FOR HOST
                      Obx(() {
                        if (controller.isHost.value) {
                          return Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Text("${controller.totalCoins.value.toInt()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => controller.leaveLive(),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Comments Area
                Expanded(
                  flex: 1, // Limited height
                  child: Obx(() => ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.comments.length,
                    itemBuilder: (context, index) {
                      // Reverse index for chat-like behavior if list is appended
                      final comment = controller.comments[controller.comments.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text.rich(
                          TextSpan(
                            text: "${comment.user.fullName}: ",
                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: comment.message,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
                ),

                // Bottom Input
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Say something...",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          onSubmitted: (val) {
                             controller.sendComment(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Like Button
                      FloatingActionButton(
                         heroTag: "like_btn",
                         mini: true,
                         backgroundColor: Colors.pinkAccent,
                         child: const Icon(Icons.favorite),
                         onPressed: () => controller.sendLike(),
                      ),
                       const SizedBox(width: 8),
                       Obx(() => Text("${controller.likeCount.value}", style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


