import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../services/socket_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService(AppConfig.serverUrl);
  ref.onDispose(service.dispose);
  return service;
}, dependencies: []);
