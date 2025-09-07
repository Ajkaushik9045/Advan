// lib/features/requests/models/item_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'item_model.g.dart';

@JsonSerializable()
class Item {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final ItemStatus status;
  final String? notes;
  final DateTime? confirmedAt;
  final String? confirmedBy;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.status,
    this.notes,
    this.confirmedAt,
    this.confirmedBy,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  Item copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    ItemStatus? status,
    String? notes,
    DateTime? confirmedAt,
    String? confirmedBy,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      confirmedBy: confirmedBy ?? this.confirmedBy,
    );
  }
}

enum ItemStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('not_available')
  notAvailable,
  @JsonValue('reassigned')
  reassigned,
}
