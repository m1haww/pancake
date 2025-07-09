// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Restaurant _$RestaurantFromJson(Map<String, dynamic> json) => Restaurant(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String,
  website: json['website'] as String,
  rating: (json['rating'] as num).toDouble(),
  image: json['image'] as String,
  recipes: (json['recipes'] as List<dynamic>)
      .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RestaurantToJson(Restaurant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'phone': instance.phone,
      'website': instance.website,
      'rating': instance.rating,
      'image': instance.image,
      'recipes': instance.recipes,
    };
