import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/restaurant.dart';
import '../models/recipe.dart';
import '../services/restaurant_service.dart';
import '../theme/app_theme.dart';
import 'recipe_detail_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  Restaurant? restaurant;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

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
    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    loadRestaurant();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadRestaurant() async {
    try {
      final loadedRestaurant = await RestaurantService.getRestaurantById(
        widget.restaurantId,
      );
      setState(() {
        restaurant = loadedRestaurant;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body:
          isLoading
              ? const Center(child: CupertinoActivityIndicator(radius: 20))
              : restaurant == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 60,
                      color: AppColors.primaryBrown.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Restaurant not found',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.primaryBrown.withValues(alpha: 0.7),
                        fontFamily: 'Gabarito',
                      ),
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: AppColors.primaryCyan,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            CupertinoIcons.arrow_left,
                            color: AppColors.primaryCyan,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              CupertinoIcons.globe,
                              color: AppColors.primaryCyan,
                              size: 20,
                            ),
                            onPressed: () => _launchUrl(restaurant!.website),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            restaurant!.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.lightCream,
                                child: Icon(
                                  CupertinoIcons.photo,
                                  size: 80,
                                  color: AppColors.primaryBrown.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
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
                          Positioned(
                            bottom: 16,
                            left: 20,
                            right: 20,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant!.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gabarito',
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.95,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              CupertinoIcons.star_fill,
                                              color: Colors.amber,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              restaurant!.rating.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.onBackground,
                                                fontFamily: 'Gabarito',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryCyan,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '${restaurant!.recipes.length} Recipes',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
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
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant!.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.onBackground.withValues(
                                    alpha: 0.8,
                                  ),
                                  height: 1.5,
                                  fontFamily: 'Gabarito',
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildContactInfo(),
                              const SizedBox(height: 24),
                              Text(
                                'Our Recipes',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBrown,
                                  fontFamily: 'Gabarito',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discover our delicious pancake varieties',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primaryBrown.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontFamily: 'Gabarito',
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildRecipesList(),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildContactRow(
            CupertinoIcons.location_solid,
            restaurant!.address,
            onTap: null,
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppColors.lightCream.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          _buildContactRow(
            CupertinoIcons.phone_fill,
            restaurant!.phone,
            onTap: () => _launchUrl('tel:${restaurant!.phone}'),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppColors.lightCream.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          _buildContactRow(
            CupertinoIcons.globe,
            restaurant!.website
                .replaceAll('https://', '')
                .replaceAll('http://', ''),
            isWebsite: true,
            onTap: () => _launchUrl(restaurant!.website),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String text, {
    bool isWebsite = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryCyan, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color:
                    isWebsite ? AppColors.primaryCyan : AppColors.onBackground,
                fontWeight: isWebsite ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Gabarito',
              ),
            ),
          ),
          if (onTap != null)
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: AppColors.primaryCyan.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
  }

  Widget _buildRecipesList() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: restaurant!.recipes.length,
      itemBuilder: (context, index) {
        final recipe = restaurant!.recipes[index];
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
              ),
            ),
            child: ModernRecipeCard(
              recipe: recipe,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder:
                        (context) => RecipeDetailScreen(
                          restaurantId: restaurant!.id,
                          recipeId: recipe.id,
                        ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ModernRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const ModernRecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            child: SizedBox(
              height: 120,
              child: Row(
                children: [
                  Container(
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
                      child:
                          recipe.image != null
                              ? Image.asset(
                                recipe.image!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      CupertinoIcons.photo,
                                      size: 40,
                                      color: AppColors.primaryBrown.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Center(
                                child: Icon(
                                  CupertinoIcons.photo,
                                  size: 40,
                                  color: AppColors.primaryBrown.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      recipe.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBrown,
                                        fontFamily: 'Gabarito',
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
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
                                        fontSize: 11,
                                        color: _getDifficultyColor(
                                          recipe.difficulty,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Gabarito',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            recipe.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.onBackground.withValues(
                                alpha: 0.7,
                              ),
                              fontFamily: 'Gabarito',
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                      color: AppColors.primaryCyan.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
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
