import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class LiveSocketService extends GetxService {
  WebSocketChannel? _channel;
  RxBool isConnected = false.obs;

  // Observables for various events
  final incomingEvents = <String, dynamic>{}.obs;
  
  // Specific event streams could be added here if needed, 
  // or controllers can listen to `incomingEvents`.

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  Future<void> connect() async {
    if (isConnected.value) return;

    final token = GetStorage().read('token');
    if (token != null) {
      try {
        final wsUrl = 'ws://eron.mtscorporate.com/api/v1/live/ws?token=$token';
        print('Connecting to Live WebSocket: $wsUrl'); 
        
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        
        // Listen to the stream to detect connection
        _channel!.stream.listen(
          (message) {
            if (!isConnected.value) {
               isConnected.value = true;
               print("Live WebSocket Connected");
            }
            print('Live WS Received: $message');
            if (message != null && message.isNotEmpty) {
              try {
                final data = jsonDecode(message);
                if (data is Map<String, dynamic>) {
                   incomingEvents.value = data;
                   incomingEvents.refresh(); 
                }
              } catch (e) {
                print('Error parsing Live WS message: $e');
              }
            }
          },
          onDone: () {
            print('Live WebSocket Closed');
            isConnected.value = false;
          },
          onError: (error) {
            print('Live WebSocket Error: $error');
            isConnected.value = false;
          },
        );
        
        // Initial wait to allow connection to establish
        await Future.delayed(const Duration(milliseconds: 500));
        if (_channel != null) {
             isConnected.value = true; 
        }

      } catch (e) {
        print('Live WebSocket Connection Failed: $e');
        isConnected.value = false;
      }
    } else {
      print("LiveSocketService: No token found");
    }
  }

  Future<void> sendAction(Map<String, dynamic> action) async {
    if (_channel == null || !isConnected.value) {
      print('Live WebSocket not connected. Attempting to connect...');
      await connect();
    }
    
    if (_channel != null && isConnected.value) {
      final jsonStr = jsonEncode(action);
      _channel!.sink.add(jsonStr);
      print('Live WS Sent: $jsonStr');
    } else {
      print('Cannot send action: Live WebSocket still not connected after retry.');
      Get.snackbar("Connection Error", "Could not connect to live server.");
    }
  }

  void close() {
    _channel?.sink.close();
    isConnected.value = false;
  }
}
