// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  prepTime: json['prepTime'] as String,
  cookTime: json['cookTime'] as String,
  servings: (json['servings'] as num).toInt(),
  difficulty: json['difficulty'] as String,
  youtubeVideoId: json['youtubeVideoId'] as String,
  image: json['image'] as String?,
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  instructions: (json['instructions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'prepTime': instance.prepTime,
  'cookTime': instance.cookTime,
  'servings': instance.servings,
  'difficulty': instance.difficulty,
  'youtubeVideoId': instance.youtubeVideoId,
  'image': instance.image,
  'ingredients': instance.ingredients,
  'instructions': instance.instructions,
};
