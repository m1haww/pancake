import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/restaurant.dart';

class FavoriteRecipe {
  final Recipe recipe;
  final Restaurant restaurant;
  final DateTime addedAt;

  FavoriteRecipe({
    required this.recipe,
    required this.restaurant,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}

class AppProvider extends ChangeNotifier {
  final List<FavoriteRecipe> _favoriteRecipes = [];
  
  // User Profile Data
  String _userName = 'Pancake Lover';
  String _userEmail = 'pancake.lover@email.com';
  String _userPhone = '';
  String _userBio = '';
  String? _profileImagePath;
  
  // Getters for user data
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userBio => _userBio;
  String? get profileImagePath => _profileImagePath;
  
  // Method to update user profile
  void updateUserProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
    String? profileImagePath,
  }) {
    _userName = name;
    _userEmail = email;
    _userPhone = phone ?? '';
    _userBio = bio ?? '';
    if (profileImagePath != null) {
      _profileImagePath = profileImagePath;
    }
    notifyListeners();
  }
  
  void updateProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  List<FavoriteRecipe> get favoriteRecipes => List.unmodifiable(_favoriteRecipes);

  bool isRecipeFavorite(String recipeId) {
    return _favoriteRecipes.any((fav) => fav.recipe.id == recipeId);
  }

  void toggleFavorite(Recipe recipe, Restaurant restaurant) {
    final index = _favoriteRecipes.indexWhere((fav) => fav.recipe.id == recipe.id);
    
    if (index >= 0) {
      _favoriteRecipes.removeAt(index);
    } else {
      _favoriteRecipes.add(FavoriteRecipe(
        recipe: recipe,
        restaurant: restaurant,
      ));
    }
    
    notifyListeners();
  }

  void removeFavorite(String recipeId) {
    _favoriteRecipes.removeWhere((fav) => fav.recipe.id == recipeId);
    notifyListeners();
  }

  void clearAllFavorites() {
    _favoriteRecipes.clear();
    notifyListeners();
  }
}