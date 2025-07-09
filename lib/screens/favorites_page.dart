import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final List<FavoriteItem> favoriteRecipes = [
    FavoriteItem(
      id: '1',
      name: 'Classic Buttermilk Pancakes',
      restaurantName: 'Golden Pancake House',
      rating: 4.8,
      difficulty: 'Easy',
      prepTime: '15 min',
    ),
    FavoriteItem(
      id: '2',
      name: 'Blueberry Pancakes',
      restaurantName: 'Golden Pancake House',
      rating: 4.7,
      difficulty: 'Easy',
      prepTime: '20 min',
    ),
    FavoriteItem(
      id: '3',
      name: 'Lemon Ricotta Pancakes',
      restaurantName: 'The Pancake Parlour',
      rating: 4.9,
      difficulty: 'Medium',
      prepTime: '25 min',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortOptions();
            },
          ),
        ],
      ),
      body: favoriteRecipes.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: AppColors.primaryBrown,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${favoriteRecipes.length} favorite recipes',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.primaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = favoriteRecipes[index];
                      return FavoriteRecipeCard(
                        recipe: recipe,
                        onTap: () {
                          // Navigate to recipe detail
                        },
                        onRemove: () {
                          _removeFavorite(recipe.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: AppColors.primaryBrown.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryBrown,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding recipes to your favorites!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryBrown.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to home page
            },
            child: const Text('Explore Recipes'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort by',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name'),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by name
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rating'),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by rating
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Prep Time'),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by prep time
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeFavorite(String id) {
    setState(() {
      favoriteRecipes.removeWhere((recipe) => recipe.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from favorites'),
        backgroundColor: AppColors.primaryCyan,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Add back to favorites
          },
        ),
      ),
    );
  }
}

class FavoriteItem {
  final String id;
  final String name;
  final String restaurantName;
  final double rating;
  final String difficulty;
  final String prepTime;

  FavoriteItem({
    required this.id,
    required this.name,
    required this.restaurantName,
    required this.rating,
    required this.difficulty,
    required this.prepTime,
  });
}

class FavoriteRecipeCard extends StatelessWidget {
  final FavoriteItem recipe;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteRecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.lightCream,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _getRecipeImage(recipe.name),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.restaurant_menu,
                        size: 30,
                        color: AppColors.primaryBrown,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.restaurantName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryCyan,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.rating.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          color: AppColors.primaryBrown.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.prepTime,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryBrown.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(recipe.difficulty).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            recipe.difficulty,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _getDifficultyColor(recipe.difficulty),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.primaryBrown;
    }
  }

  String _getRecipeImage(String recipeName) {
    switch (recipeName) {
      case 'Classic Buttermilk Pancakes':
        return 'assets/images/Classic Buttermilk Pancakes.jpg';
      case 'Blueberry Pancakes':
        return 'assets/images/Blueberry Pancakes.jpeg';
      case 'Chocolate Chip Pancakes':
        return 'assets/images/Chocolate Chip Pancakes.jpeg';
      case 'Banana Walnut Pancakes':
        return 'assets/images/Banana Walnut Pancakes.jpg';
      case 'Lemon Ricotta Pancakes':
        return 'assets/images/Lemon Ricotta Pancakes.jpg';
      default:
        return 'assets/images/Classic Buttermilk Pancakes.jpg';
    }
  }
}