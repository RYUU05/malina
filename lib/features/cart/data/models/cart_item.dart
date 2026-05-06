import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

enum Category { food, beauty }

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required String name,
    required Category category,
    required int quantity,
    String? subcategory,
    int? price,
    String? description,
    String? qrData,
    String? qrFormat,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}
