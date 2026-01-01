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

  void connect() {
    final token = GetStorage().read('token');
    if (token != null) {
      try {
        final wsUrl = 'ws://eron.mtscorporate.com/api/v1/live/ws?token=$token';
        print('Connecting to Live WebSocket: $wsUrl'); 
        
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        isConnected.value = true;
        
        _channel!.stream.listen(
          (message) {
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
      } catch (e) {
        print('Live WebSocket Connection Failed: $e');
        isConnected.value = false;
      }
    }
  }

  void sendAction(Map<String, dynamic> action) {
    if (_channel != null && isConnected.value) {
      final jsonStr = jsonEncode(action);
      _channel!.sink.add(jsonStr);
      print('Live WS Sent: $jsonStr');
    } else {
      print('Cannot send action: Live WebSocket not connected');
    }
  }

  void close() {
    _channel?.sink.close();
    isConnected.value = false;
  }
}
