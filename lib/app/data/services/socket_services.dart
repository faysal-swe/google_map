
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    // Configure the socket
    socket = IO.io('http://yourserver.com:port', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Connect to the socket
    socket.connect();

    // Handle events
    socket.onConnect((_) {
      print('Connected');
    });

    socket.onDisconnect((_) {
      print('Disconnected');
    });

    socket.on('event_name', (data) {
      print('Received data: $data');
    });
  }

  void disconnect() {
    socket.disconnect();
  }

  void sendMessage(String eventName, dynamic data) {
    socket.emit(eventName, data);
  }
}
