import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/restaurant.dart';
import '../models/recipe.dart';
import '../services/restaurant_service.dart';
import '../theme/app_theme.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String restaurantId;
  final String recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.restaurantId,
    required this.recipeId,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Restaurant? restaurant;
  Recipe? recipe;
  bool isLoading = true;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    loadRecipe();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> loadRecipe() async {
    try {
      final loadedRestaurant = await RestaurantService.getRestaurantById(widget.restaurantId);
      if (loadedRestaurant != null) {
        final foundRecipe = loadedRestaurant.recipes.firstWhere(
          (r) => r.id == widget.recipeId,
          orElse: () => throw Exception('Recipe not found'),
        );
        
        setState(() {
          restaurant = loadedRestaurant;
          recipe = foundRecipe;
          isLoading = false;
        });

        _initializeYouTubePlayer();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeYouTubePlayer() {
    if (recipe != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: recipe!.youtubeVideoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          loop: false,
          isLive: false,
          forceHD: false,
          startAt: 0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe?.name ?? 'Recipe'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipe == null
              ? const Center(child: Text('Recipe not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_youtubeController != null)
                        YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: AppColors.primaryCyan,
                          progressColors: ProgressBarColors(
                            playedColor: AppColors.primaryCyan,
                            handleColor: AppColors.primaryBrown,
                          ),
                        ),
                      if (recipe!.image != null)
                        Container(
                          width: double.infinity,
                          height: 200,
                          child: Image.asset(
                            recipe!.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.lightCream,
                                child: const Icon(
                                  Icons.restaurant,
                                  size: 60,
                                  color: AppColors.primaryBrown,
                                ),
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe!.name,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'from ${restaurant!.name}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.primaryCyan,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              recipe!.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            _buildRecipeInfo(),
                            const SizedBox(height: 24),
                            _buildIngredientsSection(),
                            const SizedBox(height: 24),
                            _buildInstructionsSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRecipeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoItem(
              Icons.schedule,
              'Prep Time',
              recipe!.prepTime,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInfoItem(
              Icons.timer,
              'Cook Time',
              recipe!.cookTime,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInfoItem(
              Icons.people,
              'Servings',
              '${recipe!.servings}',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInfoItem(
              Icons.bar_chart,
              'Difficulty',
              recipe!.difficulty,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBrown,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: AppColors.primaryBrown,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightCream.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: recipe!.ingredients.map((ingredient) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrown,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructions',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Column(
          children: recipe!.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryCyan.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      instruction,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}