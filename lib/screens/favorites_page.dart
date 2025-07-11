import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import 'recipe_detail_screen.dart';
import 'search_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _sortBy = 'dateAdded';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<FavoriteRecipe> _getSortedFavorites(List<FavoriteRecipe> favorites) {
    final sorted = List<FavoriteRecipe>.from(favorites);

    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) => a.recipe.name.compareTo(b.recipe.name));
        break;
      case 'rating':
        sorted.sort(
          (a, b) => (b.recipe.rating ?? 0).compareTo(a.recipe.rating ?? 0),
        );
        break;
      case 'difficulty':
        sorted.sort(
          (a, b) => a.recipe.difficulty.compareTo(b.recipe.difficulty),
        );
        break;
      case 'dateAdded':
      default:
        sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCyan.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.arrow_left,
                        color: AppColors.primaryCyan,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Favorites',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBrown,
                            fontFamily: 'Gabarito',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Consumer<AppProvider>(
                          builder: (context, appProvider, child) {
                            return Text(
                              '${appProvider.favoriteRecipes.length} favorite ${appProvider.favoriteRecipes.length == 1 ? 'recipe' : 'recipes'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryBrown.withValues(
                                  alpha: 0.7,
                                ),
                                fontFamily: 'Gabarito',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.sort_down,
                        color: AppColors.primaryCyan,
                      ),
                      onPressed: _showSortOptions,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  if (appProvider.favoriteRecipes.isEmpty) {
                    return _buildEmptyState();
                  }

                  final sortedFavorites = _getSortedFavorites(
                    appProvider.favoriteRecipes,
                  );

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: sortedFavorites.length,
                      itemBuilder: (context, index) {
                        final favoriteRecipe = sortedFavorites[index];
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  index * 0.1,
                                  1.0,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                            child: FavoriteRecipeCard(
                              favoriteRecipe: favoriteRecipe,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder:
                                        (context) => RecipeDetailScreen(
                                          restaurantId:
                                              favoriteRecipe.restaurant.id,
                                          recipeId: favoriteRecipe.recipe.id,
                                        ),
                                  ),
                                );
                              },
                              onRemove: () {
                                appProvider.removeFavorite(
                                  favoriteRecipe.recipe.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${favoriteRecipe.recipe.name} removed from favorites',
                                    ),
                                    backgroundColor: AppColors.primaryCyan,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        appProvider.toggleFavorite(
                                          favoriteRecipe.recipe,
                                          favoriteRecipe.restaurant,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryCyan.withValues(alpha: 0.1),
                        AppColors.secondaryCyan.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryCyan.withValues(alpha: 0.15),
                        AppColors.secondaryCyan.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryCyan, AppColors.secondaryCyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryCyan.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.heart_fill,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Your Favorites List is Empty',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
                fontFamily: 'Gabarito',
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(maxWidth: 280),
              child: Text(
                'Save your favorite pancake recipes here for quick access anytime',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onBackground.withValues(alpha: 0.6),
                  fontFamily: 'Gabarito',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryCyan, AppColors.secondaryCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCyan.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => SearchPage(showBackButton: true),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 18,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Discover Recipes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Gabarito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightCream.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.lightbulb,
                    size: 18,
                    color: AppColors.primaryBrown.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Tap the heart icon on any recipe to save it',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBrown.withValues(alpha: 0.7),
                        fontFamily: 'Gabarito',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.onBackground.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBrown,
                    fontFamily: 'Gabarito',
                  ),
                ),
                const SizedBox(height: 20),
                _buildSortOption(
                  icon: CupertinoIcons.clock,
                  title: 'Recently Added',
                  value: 'dateAdded',
                ),
                _buildSortOption(
                  icon: CupertinoIcons.textformat,
                  title: 'Name',
                  value: 'name',
                ),
                _buildSortOption(
                  icon: CupertinoIcons.star_fill,
                  title: 'Rating',
                  value: 'rating',
                ),
                _buildSortOption(
                  icon: CupertinoIcons.chart_bar_fill,
                  title: 'Difficulty',
                  value: 'difficulty',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isSelected = _sortBy == value;

    return ListTile(
      leading: Icon(
        icon,
        color:
            isSelected
                ? AppColors.primaryCyan
                : AppColors.onBackground.withValues(alpha: 0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryCyan : AppColors.onBackground,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Gabarito',
        ),
      ),
      trailing:
          isSelected
              ? Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: AppColors.primaryCyan,
              )
              : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }
}

class FavoriteRecipeCard extends StatelessWidget {
  final FavoriteRecipe favoriteRecipe;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteRecipeCard({
    super.key,
    required this.favoriteRecipe,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = favoriteRecipe.recipe;
    final restaurant = favoriteRecipe.restaurant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'favorite_${recipe.id}',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(20),
                      ),
                      color: AppColors.lightCream,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(20),
                      ),
                      child: Image.asset(
                        recipe.image ??
                            'assets/images/Classic Buttermilk Pancakes.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            CupertinoIcons.photo,
                            size: 40,
                            color: AppColors.primaryBrown.withValues(
                              alpha: 0.3,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBrown,
                                      fontFamily: 'Gabarito',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    restaurant.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primaryCyan,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Gabarito',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.heart_fill,
                                color: Colors.red,
                                size: 24,
                              ),
                              onPressed: onRemove,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (recipe.rating != null) ...[
                              Icon(
                                CupertinoIcons.star_fill,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.rating!.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onBackground,
                                  fontFamily: 'Gabarito',
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Icon(
                              CupertinoIcons.clock,
                              color: AppColors.onBackground.withValues(
                                alpha: 0.6,
                              ),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe.cookTime,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.onBackground.withValues(
                                  alpha: 0.6,
                                ),
                                fontFamily: 'Gabarito',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(
                                  recipe.difficulty,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                recipe.difficulty,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getDifficultyColor(recipe.difficulty),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gabarito',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'hard':
        return const Color(0xFFE91E63);
      default:
        return AppColors.primaryBrown;
    }
  }
}
