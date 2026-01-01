import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/live_controller.dart';
import '../../../routes/app_pages.dart';

class StartLiveView extends GetView<LiveController> {
  const StartLiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                "Start Live \nBroadcast",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
               ),
               const SizedBox(height: 40),
               TextField(
                 onChanged: (val) => controller.titleController.value = val,
                 style: const TextStyle(color: Colors.white, fontSize: 24),
                 decoration: const InputDecoration(
                   hintText: "Add a title...",
                   hintStyle: TextStyle(color: Colors.white38),
                   border: InputBorder.none,
                 ),
               ),
               const SizedBox(height: 20),
        
               Obx(() => Column(
                 children: [
                   Row(
                     children: [
                       const Text("Premium Stream", style: TextStyle(color: Colors.white, fontSize: 16)),
                       const Spacer(),
                       Switch.adaptive(
                         value: controller.isPremium.value,
                         onChanged: (val) => controller.isPremium.value = val,
                         activeColor: Colors.pinkAccent,
                       ),
                     ],
                   ),
                   if (controller.isPremium.value) ...[
                     const SizedBox(height: 20),
                     TextField(
                       keyboardType: TextInputType.number,
                       onChanged: (val) => controller.entryFee.value = double.tryParse(val) ?? 0.0,
                       style: const TextStyle(color: Colors.white, fontSize: 18),
                       decoration: const InputDecoration(
                         labelText: "Entry Fee (Coins)",
                         labelStyle: TextStyle(color: Colors.pinkAccent),
                         hintText: "Enter amount",
                         hintStyle: TextStyle(color: Colors.white38),
                         enabledBorder: OutlineInputBorder(
                           borderSide: BorderSide(color: Colors.white24),
                         ),
                         focusedBorder: OutlineInputBorder(
                           borderSide: BorderSide(color: Colors.pinkAccent),
                         ),
                       ),
                     ),
                   ]
                 ],
               )),

              const SizedBox(height: 20),
        
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                     controller.startLive();
                     // Navigate to Stream View?
                     // Logic: startLive() initializes and joins.
                     // We should navigate to LiveStreamView when ready?
                     // Or startLive handles navigation?
                     // Let's assume controller manages state, but we need to push the view.
                     Get.toNamed(Routes.LIVE_STREAM, arguments: {'isHost': true, 'channel': controller.titleController.value});
                     // Note: Backend uses generic channel names, but controller logic creates one.
                     // The controller `startLive` sets `currentChannel`.
                     // We should probably wait or navigate immediately and let controller initialize.
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.pinkAccent,
                     padding: const EdgeInsets.symmetric(vertical: 20),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   ),
                   child: const Text("START LIVE VIDEO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}
