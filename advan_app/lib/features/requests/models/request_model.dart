// lib/features/requests/models/request_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'item_model.dart';
import '../../../core/utils/enums.dart';

part 'request_model.g.dart';

@JsonSerializable()
class Request {
  final String id;
  final String userId;
  final String userName;
  final List<Item> items;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? receiverId;
  final String? receiverName;

  const Request({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.receiverId,
    this.receiverName,
  });

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequestToJson(this);

  Request copyWith({
    String? id,
    String? userId,
    String? userName,
    List<Item>? items,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? receiverId,
    String? receiverName,
  }) {
    return Request(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
    );
  }

  int get confirmedItemsCount =>
      items.where((item) => item.status == ItemStatus.confirmed).length;
  int get totalItemsCount => items.length;
  bool get isFullyConfirmed => confirmedItemsCount == totalItemsCount;
  bool get isPartiallyConfirmed =>
      confirmedItemsCount > 0 && confirmedItemsCount < totalItemsCount;
}
