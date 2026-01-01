import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/services/live_socket_service.dart';
import '../../../data/models/live_stream_model.dart';
import '../../../data/models/live_comment_model.dart';
import '../../../data/providers/live_stream_provider.dart';

class LiveController extends GetxController {
  final LiveSocketService socketService = Get.find<LiveSocketService>();
  final LiveStreamProvider provider = Get.find<LiveStreamProvider>(); // Inject Provider

  // Agora State
  late RtcEngine _engine;
  final isEngineInitialized = false.obs;
  final remoteUid = 0.obs; 
  final isJoined = false.obs;
  
  // Live State
  final currentChannel = ''.obs;
  final isHost = false.obs;
  final viewerCount = 0.obs;
  final likeCount = 0.obs;
  final comments = <LiveCommentModel>[].obs;
  
  // Setup inputs
  final titleController = ''.obs; 
  final isPremium = false.obs;
  final entryFee = 0.0.obs;

  // Constants - REPLACE WITH YOUR APP ID
  static const appId = "d828e5644c984d278f3d0572ffcda19f";

  // Helpers
  RtcEngine get engine => _engine;
  
  // Public list for Feed
  final activeStreams = <LiveStreamModel>[].obs;
  final isLoadingStreams = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to socket events
    ever(socketService.incomingEvents, handleSocketEvent);
    fetchActiveStreams(); 
  }

  Future<void> fetchActiveStreams() async {
    try {
      isLoadingStreams.value = true;
      final streams = await provider.getActiveLiveStreams();
      activeStreams.assignAll(streams);
    } catch (e) {
      print("Error fetching streams: $e");
    } finally {
      isLoadingStreams.value = false;
    }
  }

  @override
  void onClose() {
    _disposeAgora();
    WakelockPlus.disable();
    super.onClose();
  }

  Future<void> _initAgora() async {
    if (isEngineInitialized.value) return;

    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Agora: Joined ${connection.channelId}");
          isJoined.value = true;
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          print("Agora: User Joined $uid");
          remoteUid.value = uid;
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          print("Agora: User Offline $uid");
          remoteUid.value = 0;
        },
      ),
    );

    await _engine.enableVideo();
    isEngineInitialized.value = true;
  }

  Future<void> startLive() async {
    isHost.value = true;
    await _initAgora();
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.startPreview();

    // Send start_live to server
    socketService.sendAction({
      "action": "start_live",
      "is_premium": isPremium.value,
      "entry_fee": entryFee.value,
    });
    
    WakelockPlus.enable();
  }

  Future<void> joinLive(String channelName) async {
    isHost.value = false;
    currentChannel.value = channelName;
    
    await _initAgora();
    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);

    // Send join_live to server
    socketService.sendAction({
      "action": "join_live",
      "channel_name": channelName,
    });
    
    WakelockPlus.enable();
  }

  Future<void> leaveLive() async {
    if (isEngineInitialized.value) {
      await _engine.leaveChannel();
    }
    isJoined.value = false;
    isEngineInitialized.value = false;
    Get.back();
  }

  void sendLike() {
    socketService.sendAction({
      "action": "send_like",
      "channel_name": currentChannel.value,
    });
    // Optimistic update
    likeCount.value++; 
  }

  void sendComment(String text) {
     if (text.isEmpty) return;
     socketService.sendAction({
      "action": "send_comment",
      "channel_name": currentChannel.value,
      "message": text
    });
  }

  void handleSocketEvent(Map<String, dynamic> event) {
    if (event.isEmpty) return;
    final type = event['event'];
    print("LiveController Event: $type");

    switch (type) {
      case 'new_live_started':
        final data = event['data'];
        if (data != null) {
          final newStream = LiveStreamModel(
             id: '', // Not provided in event usually, or need to fetch?
             // Backend broadcast: "host_name", "host_id", "channel_name".
             // LiveStreamUser needs 'avatar' which might be missing in this event.
             host: LiveStreamUser(
               userId: data['host_id']?.toString() ?? '',
               fullName: data['host_name'] ?? 'Unknown',
               profileImage: '', 
             ),
             agoraChannelName: data['channel_name'],
             isPremium: data['is_premium'] ?? false,
             status: 'live',
          );
          activeStreams.add(newStream);
        }
        break;
        
      case 'live_ended':
        final channel = event['channel_name'];
        if (channel != null) {
           activeStreams.removeWhere((element) => element.agoraChannelName == channel);
           
           // If we are in this channel, leave
           if (currentChannel.value == channel && isJoined.value) {
              Get.snackbar("Live Ended", "The broadcast has ended.");
              leaveLive();
           }
        }
        break;

      case 'live_started':
        final token = event['agora_token'];
        final channel = event['channel_name'];
        final uid = event['uid'] ?? 0; // Backend sends fixed 1 for host
        currentChannel.value = channel;
        // Join with the assigned UID (for host)
        _joinAgoraChannel(token, channel, uid); 
        break;

      case 'joined_success':
        final channel = event['channel'];
        final token = event['agora_token']; // ব্যাকেন্ড থেকে আসা টোকেন
        final uid = event['uid'] ?? 0;
        _joinAgoraChannel(token, channel, uid);
        break;

      case 'viewer_count_update':
        viewerCount.value = event['count'];
        break;

      case 'new_like':
        likeCount.value = event['total_likes'];
        break;

      case 'new_comment':
        comments.add(LiveCommentModel.fromJson(event));
        break;
    }
  }

  Future<void> _joinAgoraChannel(String? token, String channelId, int uid) async {
    if (!isEngineInitialized.value) {
      await _initAgora();
    }


    if (isJoined.value) {
      await _engine.leaveChannel();
      isJoined.value = false;
    }

    try {

      await Future.delayed(Duration(milliseconds: 200));

      await _engine.joinChannel(
        token: token ?? '',
        channelId: channelId,
        uid: uid,
        options: ChannelMediaOptions(
          clientRoleType: isHost.value
              ? ClientRoleType.clientRoleBroadcaster
              : ClientRoleType.clientRoleAudience,
          publishCameraTrack: isHost.value,
          publishMicrophoneTrack: isHost.value,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
      print("Agora Join Requested: $channelId with uid $uid");
    } catch (e) {
      print("Agora Join Failed: $e");
    }
  }

  Future<void> _disposeAgora() async {
    if (isEngineInitialized.value) {
      await _engine.leaveChannel();
      await _engine.release();
    }
  }
}
