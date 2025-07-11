import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe {
  final String id;
  final String name;
  final String description;
  final String prepTime;
  final String cookTime;
  final int servings;
  final String difficulty;
  final String youtubeVideoId;
  final String? image;
  final List<String> ingredients;
  final List<String> instructions;
  final double? rating;
  final int? calories;
  final int? cookingTime;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.youtubeVideoId,
    this.image,
    required this.ingredients,
    required this.instructions,
    this.rating,
    this.calories,
    this.cookingTime,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}