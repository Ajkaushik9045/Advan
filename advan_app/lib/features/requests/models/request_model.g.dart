// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) => Request(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => Item.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: $enumDecode(_$RequestStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  receiverId: json['receiverId'] as String?,
  receiverName: json['receiverName'] as String?,
);

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'items': instance.items,
  'status': _$RequestStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'receiverId': instance.receiverId,
  'receiverName': instance.receiverName,
};

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'pending',
  RequestStatus.confirmed: 'confirmed',
  RequestStatus.partiallyFulfilled: 'partially_fulfilled',
};
