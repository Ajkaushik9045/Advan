// lib/features/requests/services/request_service.dart
import '../../../core/network/api_client.dart';
import '../models/request_model.dart';
import '../models/item_model.dart';
import '../../../core/utils/enums.dart';

class RequestService {
  final ApiClient apiClient;

  RequestService({required this.apiClient});

  Future<List<Request>> getMyRequests() async {
    try {
      final response = await apiClient.get('/api/requests/my');
      final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => _mapBackendRequestToFrontend(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch my requests: $e');
    }
  }

  Future<List<Request>> getReceiverAssignedRequests() async {
    try {
      final response = await apiClient.get('/api/receiver/requests');
      final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => _mapBackendRequestToFrontend(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch assigned requests: $e');
    }
  }

  Future<Request> createRequest({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // Backend expects items as [{ itemId, quantity }]
      final payload = {'items': items};
      final response = await apiClient.post('/api/requests', data: payload);
      final data = response.data['data'];
      return _mapBackendRequestToFrontend(data);
    } catch (e) {
      throw Exception('Failed to create request: $e');
    }
  }

  // Status updates are driven by item confirmations on backend; kept if needed
  Future<Request> refreshRequest({required String requestId}) async {
    try {
      // Receiver flow has GET /api/receiver/requests/:id
      final response = await apiClient.get('/api/receiver/requests/$requestId');
      final data = response.data['data'];
      return _mapBackendRequestToFrontend(data);
    } catch (e) {
      throw Exception('Failed to refresh request: $e');
    }
  }

  Future<Request> confirmItems({
    required String requestId,
    required List<Map<String, dynamic>> itemConfirmations,
  }) async {
    try {
      // itemConfirmations: [{ itemId: string, available: bool }]
      for (final c in itemConfirmations) {
        await apiClient.patch(
          '/api/receiver/requests/$requestId/items/' + c['itemId'],
          data: {'available': c['available'] == true},
        );
      }
      return await refreshRequest(requestId: requestId);
    } catch (e) {
      throw Exception('Failed to confirm items: $e');
    }
  }

  Future<List<Item>> getAvailableItems() async {
    try {
      final response = await apiClient.get('/api/items');
      final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
      // Backend doesn't provide status for inventory items; default to pending
      return data
          .map((json) => _mapBackendInventoryItemToFrontend(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch available items: $e');
    }
  }

  // ---- Mapping helpers ----
  Request _mapBackendRequestToFrontend(Map<String, dynamic> json) {
    final backendStatus = (json['status'] as String?) ?? 'Pending';
    final normalizedStatus = backendStatus.toLowerCase() == 'partiallyfulfilled'
        ? 'partially_fulfilled'
        : backendStatus.toLowerCase();

    final requester = json['requester'];
    final requesterId = requester is Map<String, dynamic>
        ? (requester['id'] ?? requester['_id'] ?? '')
        : (requester?.toString() ?? '');
    final requesterName = requester is Map<String, dynamic>
        ? (requester['userName'] ?? requester['name'] ?? '')
        : '';

    final assignedTo = json['assignedTo'];
    final receiverId = assignedTo is Map<String, dynamic>
        ? (assignedTo['id'] ?? assignedTo['_id'])?.toString()
        : (assignedTo?.toString());
    final receiverName = assignedTo is Map<String, dynamic>
        ? (assignedTo['userName'] ?? assignedTo['name'])?.toString()
        : null;

    final items = (json['items'] as List<dynamic>? ?? []).map((it) {
      final m = it as Map<String, dynamic>;
      final available = (m['available'] == true);
      final itemInfo = m['item'];
      final itemName =
          (m['name'] ??
                  (itemInfo is Map<String, dynamic>
                      ? itemInfo['name']
                      : null) ??
                  '')
              .toString();
      final itemId =
          (itemInfo is Map<String, dynamic>
                  ? (itemInfo['id'] ?? itemInfo['_id'])
                  : (itemInfo))
              ?.toString() ??
          '';
      return Item(
        id: itemId,
        name: itemName,
        description:
            (itemInfo is Map<String, dynamic>
                    ? (itemInfo['description'] ?? '')
                    : '')
                .toString(),
        quantity: (m['quantity'] as num?)?.toInt() ?? 1,
        status: available ? ItemStatus.confirmed : ItemStatus.pending,
        notes: null,
        confirmedAt: null,
        confirmedBy: (m['confirmedBy']?.toString()),
      );
    }).toList();

    return Request(
      id: (json['id'] ?? json['_id']).toString(),
      userId: requesterId,
      userName: requesterName,
      items: items,
      status: _parseStatus(normalizedStatus),
      createdAt: DateTime.parse(
        (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      receiverId: receiverId,
      receiverName: receiverName,
    );
  }

  Item _mapBackendInventoryItemToFrontend(Map<String, dynamic> json) {
    return Item(
      id: (json['id'] ?? json['_id']).toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      status: ItemStatus.pending,
      notes: null,
      confirmedAt: null,
      confirmedBy: null,
    );
  }

  RequestStatus _parseStatus(String s) {
    switch (s) {
      case 'confirmed':
        return RequestStatus.confirmed;
      case 'partially_fulfilled':
        return RequestStatus.partiallyFulfilled;
      default:
        return RequestStatus.pending;
    }
  }
}
