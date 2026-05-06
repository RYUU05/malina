// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemImpl _$$CartItemImplFromJson(Map<String, dynamic> json) =>
    _$CartItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      quantity: (json['quantity'] as num).toInt(),
      subcategory: json['subcategory'] as String?,
      price: (json['price'] as num?)?.toInt(),
      description: json['description'] as String?,
      qrData: json['qrData'] as String?,
      qrFormat: json['qrFormat'] as String?,
    );

Map<String, dynamic> _$$CartItemImplToJson(_$CartItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': _$CategoryEnumMap[instance.category]!,
      'quantity': instance.quantity,
      'subcategory': instance.subcategory,
      'price': instance.price,
      'description': instance.description,
      'qrData': instance.qrData,
      'qrFormat': instance.qrFormat,
    };

const _$CategoryEnumMap = {Category.food: 'food', Category.beauty: 'beauty'};
