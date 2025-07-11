import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../models/recipe.dart';
import '../services/restaurant_service.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

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

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with TickerProviderStateMixin {
  Restaurant? restaurant;
  Recipe? recipe;
  bool isLoading = true;
  YoutubePlayerController? _youtubeController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  Set<int> checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showAppBarTitle) {
        setState(() => _showAppBarTitle = true);
      } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
        setState(() => _showAppBarTitle = false);
      }
    });
    
    loadRecipe();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _animationController.dispose();
    _scrollController.dispose();
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
        _animationController.forward();
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

  void _shareRecipe() {
    if (recipe != null && restaurant != null) {
      final ingredients = recipe!.ingredients.map((i) => '• $i').join('\n');
      final instructions = recipe!.instructions.asMap().entries
          .map((e) => '${e.key + 1}. ${e.value}')
          .join('\n');
      
      final shareText = '''
🥞 ${recipe!.name}
📍 From ${restaurant!.name}

📝 Description:
${recipe!.description}

⏱️ Cook Time: ${recipe!.cookTime}
👥 Servings: ${recipe!.servings}
📊 Difficulty: ${recipe!.difficulty}
${recipe!.calories != null ? '🔥 Calories: ${recipe!.calories}' : ''}

🛒 Ingredients:
$ingredients

📋 Instructions:
$instructions

Shared from Pancake Paradise App 🥞
''';

      Share.share(
        shareText,
        subject: '${recipe!.name} Recipe',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 20))
          : recipe == null
              ? const Center(child: Text('Recipe not found'))
              : Stack(
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        _buildSliverAppBar(),
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                _buildRecipeHeader(),
                                _buildMetadataCards(),
                                if (_youtubeController != null) _buildVideoSection(),
                                _buildIngredientsSection(),
                                _buildInstructionsSection(),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildFloatingButtons(),
                  ],
                ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: AppColors.primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          recipe?.name ?? '',
          style: TextStyle(
            color: AppColors.primaryBrown,
            fontWeight: FontWeight.bold,
            fontFamily: 'Gabarito',
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'recipe_${recipe?.id}',
              child: Image.asset(
                recipe?.image ?? 'assets/images/Classic Buttermilk Pancakes.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.lightCream,
                    child: Icon(
                      CupertinoIcons.photo,
                      size: 60,
                      color: AppColors.primaryBrown.withValues(alpha: 0.3),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
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
                      recipe!.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBrown,
                        fontFamily: 'Gabarito',
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.building_2_fill,
                            size: 16,
                            color: AppColors.primaryCyan,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            restaurant!.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryCyan,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Gabarito',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (recipe?.rating != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.star_fill,
                        size: 18,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe!.rating!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBrown,
                          fontFamily: 'Gabarito',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recipe!.description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.onBackground.withValues(alpha: 0.8),
              fontFamily: 'Gabarito',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCards() {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildMetadataCard(
            icon: CupertinoIcons.clock,
            label: 'Cook Time',
            value: recipe!.cookTime,
            color: AppColors.primaryCyan,
          ),
          _buildMetadataCard(
            icon: CupertinoIcons.flame,
            label: 'Calories',
            value: '${recipe?.calories ?? 350}',
            color: Colors.orange,
          ),
          _buildMetadataCard(
            icon: CupertinoIcons.person_2,
            label: 'Servings',
            value: '${recipe!.servings}',
            color: Colors.green,
          ),
          _buildMetadataCard(
            icon: CupertinoIcons.chart_bar_fill,
            label: 'Difficulty',
            value: recipe!.difficulty,
            color: AppColors.primaryBrown,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: color,
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
                fontFamily: 'Gabarito',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onBackground.withValues(alpha: 0.6),
                fontFamily: 'Gabarito',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.primaryCyan,
              progressColors: ProgressBarColors(
                playedColor: AppColors.primaryCyan,
                handleColor: AppColors.primaryBrown,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.play_circle_fill,
                    color: AppColors.primaryCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Video Tutorial',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBrown,
                      fontFamily: 'Gabarito',
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

  Widget _buildIngredientsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.cart_fill,
                  color: AppColors.primaryBrown,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBrown,
                  fontFamily: 'Gabarito',
                ),
              ),
              const Spacer(),
              Text(
                '${recipe!.ingredients.length} items',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onBackground.withValues(alpha: 0.6),
                  fontFamily: 'Gabarito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...recipe!.ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            final isChecked = checkedIngredients.contains(index);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isChecked) {
                    checkedIngredients.remove(index);
                  } else {
                    checkedIngredients.add(index);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isChecked 
                      ? AppColors.primaryCyan.withValues(alpha: 0.05)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isChecked 
                        ? AppColors.primaryCyan.withValues(alpha: 0.3)
                        : AppColors.onBackground.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isChecked ? AppColors.primaryCyan : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isChecked 
                              ? AppColors.primaryCyan 
                              : AppColors.onBackground.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: isChecked
                          ? Icon(
                              CupertinoIcons.checkmark_alt,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: TextStyle(
                          fontSize: 16,
                          color: isChecked 
                              ? AppColors.onBackground.withValues(alpha: 0.5)
                              : AppColors.onBackground,
                          fontFamily: 'Gabarito',
                          decoration: isChecked 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.list_number,
                    color: AppColors.primaryCyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBrown,
                    fontFamily: 'Gabarito',
                  ),
                ),
                const Spacer(),
                Text(
                  '${recipe!.instructions.length} steps',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onBackground.withValues(alpha: 0.6),
                    fontFamily: 'Gabarito',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...recipe!.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            final isLast = index == recipe!.instructions.length - 1;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryCyan, AppColors.secondaryCyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Gabarito',
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 80,
                        color: AppColors.primaryCyan.withValues(alpha: 0.2),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryCyan.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      instruction,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onBackground,
                        fontFamily: 'Gabarito',
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Column(
        children: [
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              final isFavorite = recipe != null ? appProvider.isRecipeFavorite(recipe!.id) : false;
              return FloatingActionButton(
                heroTag: 'favorite',
                backgroundColor: Colors.white,
                elevation: 10,
                onPressed: recipe != null && restaurant != null
                    ? () => appProvider.toggleFavorite(recipe!, restaurant!)
                    : null,
                child: Icon(
                  isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: isFavorite ? Colors.red : AppColors.primaryBrown,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'share',
            backgroundColor: AppColors.primaryCyan,
            elevation: 10,
            onPressed: () => _shareRecipe(),
            child: Icon(
              CupertinoIcons.share,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}