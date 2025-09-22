import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/config/config.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final socketProvider = Provider<io.Socket>((ref) {
  final socket = io.io(Environment.apiUrl, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true, 
  });

  // Solo conectar si no está ya conectado o conectando
  if (socket.disconnected) {
    socket.connect();
  }

  ref.onDispose(() {
    socket.dispose();
  });

  return socket;
});
