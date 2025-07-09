import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/recipe.dart';
import '../services/restaurant_service.dart';
import '../theme/app_theme.dart';
import 'restaurant_detail_screen.dart';
import 'recipe_detail_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> allRestaurants = [];
  List<SearchResult> searchResults = [];
  bool isLoading = false;
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    loadRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      appBar: AppBar(
        title: const Text('Search Recipes'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurants, recipes, or ingredients...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          performSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: performSearch,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : !hasSearched
                    ? _buildSearchSuggestions()
                    : searchResults.isEmpty
                        ? _buildNoResults()
                        : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 100,
            color: AppColors.primaryBrown.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for your favorite pancake recipes',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryBrown,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for "blueberry", "chocolate", or a restaurant name',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryBrown.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Blueberry'),
              _buildSuggestionChip('Chocolate'),
              _buildSuggestionChip('Banana'),
              _buildSuggestionChip('Buttermilk'),
              _buildSuggestionChip('Lemon'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        performSearch(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryCyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.primaryCyan,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 100,
            color: AppColors.primaryBrown.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryBrown,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryBrown.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final result = searchResults[index];
        return SearchResultCard(
          result: result,
          onTap: () {
            if (result.type == SearchResultType.restaurant) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailScreen(
                    restaurantId: result.restaurant.id,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(
                    restaurantId: result.restaurant.id,
                    recipeId: result.recipe!.id,
                  ),
                ),
              );
            }
          },
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

class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.lightCream,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: result.type == SearchResultType.restaurant
                ? Image.asset(
                    result.restaurant.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.restaurant,
                        color: AppColors.primaryBrown,
                      );
                    },
                  )
                : Image.asset(
                    result.recipe?.image ?? 'assets/images/Classic Buttermilk Pancakes.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.restaurant_menu,
                        color: AppColors.primaryBrown,
                      );
                    },
                  ),
          ),
        ),
        title: Text(
          result.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(result.subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.primaryBrown.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }
}