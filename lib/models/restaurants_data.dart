import 'package:json_annotation/json_annotation.dart';
import 'restaurant.dart';

part 'restaurants_data.g.dart';

@JsonSerializable()
class RestaurantsData {
  final List<Restaurant> restaurants;

  RestaurantsData({required this.restaurants});

  factory RestaurantsData.fromJson(Map<String, dynamic> json) => _$RestaurantsDataFromJson(json);
  Map<String, dynamic> toJson() => _$RestaurantsDataToJson(this);
}