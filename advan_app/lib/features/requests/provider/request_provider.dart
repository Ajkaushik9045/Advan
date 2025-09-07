// lib/features/requests/provider/request_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../auth/provider/auth_provider.dart';

import '../../../core/network/api_client.dart';
import '../models/request_model.dart';
import '../models/item_model.dart';
import '../services/request_service.dart';

class RequestProvider extends ChangeNotifier {
  final RequestService _requestService;
  final String wsUrl;
  WebSocketChannel? _channel;
  Timer? _pollTimer;

  List<Request> _requests = [];
  List<Item> _availableItems = [];
  bool _isLoading = false;
  String? _error;

  List<Request> get requests => _requests;
  List<Item> get availableItems => _availableItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RequestProvider({required ApiClient apiClient, required this.wsUrl})
    : _requestService = RequestService(apiClient: apiClient) {
    fetchAll();
    // _initWebsocket();
  }

  Future<void> fetchAll({AuthProvider? auth}) async {
    await Future.wait([fetchAvailableItems(), fetchRequests(auth: auth, receiverId: 'receiver-${auth?.role?.name ?? 'receiver'}')]);
  }

  Future<void> fetchRequests({AuthProvider? auth, required String receiverId}) async {
    _setLoading(true);
    try {
      if (auth != null && auth.role == UserRole.receiver) {
        _requests = await _requestService.getReceiverAssignedRequests();
      } else {
        _requests = await _requestService.getMyRequests();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAvailableItems() async {
    try {
      _availableItems = await _requestService.getAvailableItems();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> createRequest({
    required List<Map<String, dynamic>> items,
    required dynamic auth,
  }) async {
    _setLoading(true);
    try {
      await _requestService.createRequest(items: items);
      await fetchRequests(receiverId: 'receiver-${auth?.role?.name ?? 'receiver'}');
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> confirmItems({
    required String requestId,
    required List<Map<String, dynamic>> itemConfirmations,
    required dynamic auth,
  }) async {
    _setLoading(true);
    try {
      await _requestService.confirmItems(
        requestId: requestId,
        itemConfirmations: itemConfirmations,
      );
      await fetchRequests(receiverId: 'receiver-${auth?.role?.name ?? 'receiver'}');
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // void _initWebsocket() {
  //   try {
  //     _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  //     _channel!.stream.listen(
  //       (message) {
  //         // Simplest: refetch list
  //         fetchRequests(receiverId: 'receiver-${auth?.role?.name ?? 'receiver'}');
  //       },
  //       onError: (_) {
  //         _startPolling();
  //       },
  //       onDone: () {
  //         _startPolling();
  //       },
  //     );
  //   } catch (e) {
  //     _startPolling();
  //   }
  // }

  // void _startPolling() {
  //   _pollTimer?.cancel();
  //   _pollTimer = Timer.periodic(
  //     const Duration(seconds: 8),
  //     (_, dynamic auth) => fetchRequests(receiverId: 'receiver-${auth?.role?.name ?? 'receiver'}'),
  //   );
  // }

  @override
  void dispose() {
    _channel?.sink.close();
    _pollTimer?.cancel();
    super.dispose();
  }
}
