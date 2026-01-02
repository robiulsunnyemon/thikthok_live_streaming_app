import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.user.value?.fullName ?? "Profile", 
          style: const TextStyle(fontWeight: FontWeight.bold)
        )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {}, // Settings
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
        }
        
        final user = controller.user.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Failed to load profile", style: TextStyle(color: Colors.white)),
                TextButton(
                  onPressed: () => controller.fetchProfile(),
                  child: const Text("Retry", style: TextStyle(color: Colors.pinkAccent)),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          color: Colors.pinkAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Image
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade800, width: 1),
                      image: DecorationImage(
                        image: NetworkImage(user.profileImage ?? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Name & Username
                Text(
                  "@${user.firstName?.toLowerCase()}${user.lastName?.toLowerCase()}", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                ),
                const SizedBox(height: 20),
                
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatItem("Following", "${user.followingCount ?? 0}"),
                    Container(height: 20, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
                    _buildStatItem("Followers", "${user.followersCount ?? 0}"),
                    Container(height: 20, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
                    _buildStatItem("Likes", "${user.totalLike ?? 0}"), // API doesn't have total likes yet? Using 0 for now.
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton("Edit profile", () {}),
                    const SizedBox(width: 8),
                    _buildActionButton("Share profile", () {}),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Bio
                if (user.bio != null && user.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),

                const SizedBox(height: 20),
                
                // Wallet / Coins Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.amber),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Balance", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text("${user.coins ?? 0} Coins", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {}, // Topup flow
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                        child: const Text("Top Up"),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                // Tab Bar placeholder for Videos/Likes
                const DefaultTabController(
                  length: 3, 
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: Colors.amber,
                        tabs: [
                          Tab(icon: Icon(Icons.grid_on)),
                          Tab(icon: Icon(Icons.favorite_border)),
                          Tab(icon: Icon(Icons.lock_outline)),
                        ],
                      ),
                      SizedBox(
                        height: 300,
                        child: Center(child: Text("No videos yet", style: TextStyle(color: Colors.white54))),
                      )
                    ],
                  )
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
