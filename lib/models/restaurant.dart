import 'package:json_annotation/json_annotation.dart';
import 'recipe.dart';

part 'restaurant.g.dart';

@JsonSerializable()
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String website;
  final double rating;
  final String image;
  final List<Recipe> recipes;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.website,
    required this.rating,
    required this.image,
    required this.recipes,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => _$RestaurantFromJson(json);
  Map<String, dynamic> toJson() => _$RestaurantToJson(this);
}