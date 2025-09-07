// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  quantity: (json['quantity'] as num).toInt(),
  status: $enumDecode(_$ItemStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
  confirmedAt: json['confirmedAt'] == null
      ? null
      : DateTime.parse(json['confirmedAt'] as String),
  confirmedBy: json['confirmedBy'] as String?,
);

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'quantity': instance.quantity,
  'status': _$ItemStatusEnumMap[instance.status]!,
  'notes': instance.notes,
  'confirmedAt': instance.confirmedAt?.toIso8601String(),
  'confirmedBy': instance.confirmedBy,
};

const _$ItemStatusEnumMap = {
  ItemStatus.pending: 'pending',
  ItemStatus.confirmed: 'confirmed',
  ItemStatus.notAvailable: 'not_available',
  ItemStatus.reassigned: 'reassigned',
};
