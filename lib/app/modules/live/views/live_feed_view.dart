import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/live_controller.dart';
import '../../../routes/app_pages.dart';
//import '../../../data/models/live_stream_model.dart';

class LiveFeedView extends GetView<LiveController> {
  const LiveFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller might need to be put here or binding handles it
    // For the list, implementation plan mentioned listening to 'new_live_started'.
    // We should probably rely on a list in controller.
    // Assuming controller has `activeStreams` (not yet added, I'll update controller later or mock it here for UI).
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Live Feed', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
             icon: const Icon(Icons.search, color: Colors.white),
             onPressed: (){},
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF1A1A1A)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.live_tv, size: 80, color: Colors.white24),
              const SizedBox(height: 20),
              const Text(
                "Explore Live Streams",
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
              const SizedBox(height: 20),
              
              // LIVE LIST
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingStreams.value) {
                    return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
                  }
                  if (controller.activeStreams.isEmpty) {
                    return const Center(child: Text("No live streams yet.", style: TextStyle(color: Colors.white38)));
                  }
                  return ListView.builder(
                    itemCount: controller.activeStreams.length,
                    itemBuilder: (context, index) {
                      final stream = controller.activeStreams[index];
                      // Use refresh indicator if needed, but for now just list
                      return Card(
                        color: Colors.white12,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                             backgroundColor: Colors.pinkAccent,
                             backgroundImage: stream.host.profileImage.isNotEmpty ? NetworkImage(stream.host.profileImage) : null,
                             child: stream.host.profileImage.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                          ),
                          title: Text(stream.host.fullName, style: const TextStyle(color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stream.isPremium ? "Premium • \$${stream.entryFee}" : "Free", style: const TextStyle(color: Colors.white54)),
                              Row(
                                children: [
                                  const Icon(Icons.remove_red_eye, size: 12, color: Colors.white30),
                                  const SizedBox(width: 4),
                                  Text("${stream.totalViews}", style: const TextStyle(color: Colors.white30, fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(Routes.LIVE_STREAM, arguments: {'isHost': false, 'channel': stream.agoraChannelName});
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                            child: const Text("Watch"),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.START_LIVE),
                icon: const Icon(Icons.videocam),
                label: const Text("GO LIVE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
