import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../cart/domain/entities/cart_item.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String username,
    required String passwordHash,
    required int failedAttempts,
    @Default([]) List<CartItem> cartItems,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
