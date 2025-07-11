import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../theme/app_theme.dart';
import 'restaurant_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = {};
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 11.0,
  );

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      final restaurants = await RestaurantService.loadRestaurants();
      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
      _loadMarkers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMarkers() {
    
    setState(() {
      _markers.clear();
      for (final restaurant in _restaurants) {
        _markers.add(
          Marker(
            markerId: MarkerId(restaurant.id),
            position: LatLng(restaurant.latitude, restaurant.longitude),
            infoWindow: InfoWindow(
              title: restaurant.name,
              snippet: restaurant.address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailScreen(
                    restaurantId: restaurant.id,
                  ),
                ),
              );
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restaurant Locations',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryCyan,
              ),
            )
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                // Map controller is ready
              },
              initialCameraPosition: _initialPosition,
              markers: _markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
            ),
    );
  }
}