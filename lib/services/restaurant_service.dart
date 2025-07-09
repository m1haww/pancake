import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/restaurants_data.dart';
import '../models/restaurant.dart';

class RestaurantService {
  static Future<List<Restaurant>> loadRestaurants() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/restaurants.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final RestaurantsData restaurantsData = RestaurantsData.fromJson(jsonData);
      return restaurantsData.restaurants;
    } catch (e) {
      print('Error loading restaurants: $e');
      return [];
    }
  }
  
  static Future<Restaurant?> getRestaurantById(String id) async {
    final restaurants = await loadRestaurants();
    try {
      return restaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      return null;
    }
  }
}