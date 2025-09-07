import 'package:json_annotation/json_annotation.dart';

enum RequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('partially_fulfilled')
  partiallyFulfilled,
}
