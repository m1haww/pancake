import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/restaurant.dart';
import '../models/recipe.dart';
import '../services/restaurant_service.dart';
import '../theme/app_theme.dart';
import 'restaurant_detail_screen.dart';
import 'recipe_detail_screen.dart';

class SearchPage extends StatefulWidget {
  final bool showBackButton;
  
  const SearchPage({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Restaurant> allRestaurants = [];
  List<SearchResult> searchResults = [];
  bool isLoading = false;
  bool hasSearched = false;
  List<String> recentSearches = ['Blueberry', 'Chocolate', 'Banana'];

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
    loadRestaurants();
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadRestaurants() async {
    final restaurants = await RestaurantService.loadRestaurants();
    setState(() {
      allRestaurants = restaurants;
    });
  }

  void performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        hasSearched = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    List<SearchResult> results = [];
    
    for (final restaurant in allRestaurants) {
      if (restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
          restaurant.description.toLowerCase().contains(query.toLowerCase())) {
        results.add(SearchResult(
          type: SearchResultType.restaurant,
          restaurant: restaurant,
          title: restaurant.name,
          subtitle: restaurant.description,
        ));
      }
      
      for (final recipe in restaurant.recipes) {
        if (recipe.name.toLowerCase().contains(query.toLowerCase()) ||
            recipe.description.toLowerCase().contains(query.toLowerCase()) ||
            recipe.ingredients.any((ingredient) => 
                ingredient.toLowerCase().contains(query.toLowerCase()))) {
          results.add(SearchResult(
            type: SearchResultType.recipe,
            restaurant: restaurant,
            recipe: recipe,
            title: recipe.name,
            subtitle: 'from ${restaurant.name}',
          ));
        }
      }
    }

    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      if (widget.showBackButton) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              CupertinoIcons.arrow_left,
                              color: AppColors.primaryCyan,
                              size: 24,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBrown,
                            fontFamily: 'Gabarito',
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            performSearch('');
                            _searchFocusNode.unfocus();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryCyan,
                              fontFamily: 'Gabarito',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _searchFocusNode.hasFocus 
                            ? AppColors.primaryCyan 
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Gabarito',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search restaurants, recipes...',
                        hintStyle: TextStyle(
                          color: AppColors.onBackground.withValues(alpha: 0.5),
                          fontFamily: 'Gabarito',
                        ),
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: AppColors.onBackground.withValues(alpha: 0.5),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.onBackground.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.xmark,
                                    size: 16,
                                    color: AppColors.onBackground,
                                  ),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  performSearch('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: performSearch,
                      onTap: () => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(radius: 20),
                    )
                  : !hasSearched
                      ? _buildSearchSuggestions()
                      : searchResults.isEmpty
                          ? _buildNoResults()
                          : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBrown,
              fontFamily: 'Gabarito',
            ),
          ),
          const SizedBox(height: 16),
          ...recentSearches.map((search) => _buildRecentSearchItem(search)),
          const SizedBox(height: 32),
          Text(
            'Popular Ingredients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBrown,
              fontFamily: 'Gabarito',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSuggestionChip('Blueberry', CupertinoIcons.circle_fill, Colors.blue),
              _buildSuggestionChip('Chocolate', CupertinoIcons.circle_fill, Colors.brown),
              _buildSuggestionChip('Banana', CupertinoIcons.circle_fill, Colors.amber),
              _buildSuggestionChip('Buttermilk', CupertinoIcons.circle_fill, AppColors.lightCream),
              _buildSuggestionChip('Lemon', CupertinoIcons.circle_fill, Colors.yellow),
              _buildSuggestionChip('Strawberry', CupertinoIcons.circle_fill, Colors.red),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryCyan.withValues(alpha: 0.1),
                  AppColors.secondaryCyan.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.search_circle_fill,
                  size: 60,
                  color: AppColors.primaryCyan,
                ),
                const SizedBox(height: 12),
                Text(
                  'Search Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBrown,
                    fontFamily: 'Gabarito',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching for specific ingredients, restaurant names, or pancake types',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onBackground.withValues(alpha: 0.7),
                    fontFamily: 'Gabarito',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _searchController.text = text;
          performSearch(text);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCyan.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                size: 18,
                color: AppColors.onBackground.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.onBackground,
                    fontFamily: 'Gabarito',
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.arrow_up_left,
                size: 18,
                color: AppColors.onBackground.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        performSearch(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryCyan.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w600,
                fontFamily: 'Gabarito',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.lightCream.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.search,
                  size: 60,
                  color: AppColors.primaryBrown.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No results found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBrown,
                  fontFamily: 'Gabarito',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onBackground.withValues(alpha: 0.7),
                  fontFamily: 'Gabarito',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final result = searchResults[index];
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.05,
                1.0,
                curve: Curves.easeOutCubic,
              ),
            )),
            child: ModernSearchResultCard(
              result: result,
              onTap: () {
                if (result.type == SearchResultType.restaurant) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => RestaurantDetailScreen(
                        restaurantId: result.restaurant.id,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        restaurantId: result.restaurant.id,
                        recipeId: result.recipe!.id,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

enum SearchResultType { restaurant, recipe }

class SearchResult {
  final SearchResultType type;
  final Restaurant restaurant;
  final Recipe? recipe;
  final String title;
  final String subtitle;

  SearchResult({
    required this.type,
    required this.restaurant,
    this.recipe,
    required this.title,
    required this.subtitle,
  });
}

class ModernSearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const ModernSearchResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRecipe = result.type == SearchResultType.recipe;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Hero(
                  tag: isRecipe ? 'recipe_${result.recipe?.id}' : 'restaurant_${result.restaurant.id}',
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      color: AppColors.lightCream,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            isRecipe 
                                ? (result.recipe?.image ?? 'assets/images/Classic Buttermilk Pancakes.jpg')
                                : result.restaurant.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.lightCream,
                                child: Icon(
                                  isRecipe 
                                      ? CupertinoIcons.doc_text_fill
                                      : CupertinoIcons.building_2_fill,
                                  size: 40,
                                  color: AppColors.primaryBrown.withValues(alpha: 0.3),
                                ),
                              );
                            },
                          ),
                          if (isRecipe)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.clock,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${result.recipe?.cookingTime ?? 25} min',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Gabarito',
                                      ),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isRecipe
                                          ? [AppColors.primaryBrown, AppColors.primaryBrown.withValues(alpha: 0.8)]
                                          : [AppColors.primaryCyan, AppColors.secondaryCyan],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isRecipe ? 'Recipe' : 'Restaurant',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Gabarito',
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (isRecipe && result.recipe?.rating != null)
                                  Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.star_fill,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        result.recipe!.rating!.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onBackground,
                                          fontFamily: 'Gabarito',
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              result.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onBackground,
                                fontFamily: 'Gabarito',
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              result.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onBackground.withValues(alpha: 0.6),
                                fontFamily: 'Gabarito',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        if (isRecipe && result.recipe?.calories != null)
                          Wrap(
                            spacing: 6,
                            children: [
                              _buildInfoChip(
                                icon: CupertinoIcons.flame,
                                text: '${result.recipe!.calories} cal',
                                color: Colors.orange,
                              ),
                              _buildInfoChip(
                                icon: CupertinoIcons.chart_bar_fill,
                                text: result.recipe!.difficulty,
                                color: AppColors.primaryCyan,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.arrow_right,
                      size: 16,
                      color: AppColors.primaryCyan,
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

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: 'Gabarito',
            ),
          ),
        ],
      ),
    );
  }
}