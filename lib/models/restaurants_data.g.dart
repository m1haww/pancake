// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurants_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantsData _$RestaurantsDataFromJson(Map<String, dynamic> json) =>
    RestaurantsData(
      restaurants: (json['restaurants'] as List<dynamic>)
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RestaurantsDataToJson(RestaurantsData instance) =>
    <String, dynamic>{'restaurants': instance.restaurants};
