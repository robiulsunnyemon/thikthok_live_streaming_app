import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService extends GetxService {
  WebSocketChannel? _channel;
  RxBool isConnected = false.obs;
  
  // Observable to listen for incoming messages in controllers
  final incomingMessages = ''.obs;

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  void connect() {
    final token = GetStorage().read('token');
    if (token != null) {
      try {
        final wsUrl = 'ws://eron.mtscorporate.com/api/v1/chat/ws?token=$token';
        print('Connecting to WebSocket: $wsUrl'); // Debug
        
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        isConnected.value = true;
        
        _channel!.stream.listen(
          (message) {
            print('Received message: $message'); // Debug
            incomingMessages.value = message;
            incomingMessages.refresh(); // Trigger update even if message is same
          },
          onDone: () {
            print('WebSocket Closed');
            isConnected.value = false;
            // Optional: Implement reconnect logic here
          },
          onError: (error) {
            print('WebSocket Error: $error');
            isConnected.value = false;
          },
        );
      } catch (e) {
        print('WebSocket Connection Failed: $e');
        isConnected.value = false;
      }
    } else {
      print('No token found for WebSocket connection');
    }
  }

  void sendMessage(String message) {
    if (_channel != null && isConnected.value) {
      _channel!.sink.add(message);
    } else {
      print('Cannot send message: WebSocket not connected');
    }
  }

  void close() {
    _channel?.sink.close();
    isConnected.value = false;
  }
}
