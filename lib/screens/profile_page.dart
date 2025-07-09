import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pancake Lover',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryBrown,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'pancake.lover@email.com',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.primaryBrown.withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Edit profile
                    },
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Recipes Tried', '23'),
                  _buildStatItem('Favorites', '12'),
                  _buildStatItem('Reviews', '8'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryCyan,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryBrown.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.history,
            'Recent Recipes',
            'View your recently viewed recipes',
            () {
              // Navigate to recent recipes
            },
          ),
          _buildMenuItem(
            Icons.bookmark,
            'Saved Recipes',
            'Your bookmarked recipes',
            () {
              // Navigate to saved recipes
            },
          ),
          _buildMenuItem(
            Icons.star,
            'My Reviews',
            'Reviews you\'ve written',
            () {
              // Navigate to reviews
            },
          ),
          _buildMenuItem(
            Icons.restaurant,
            'Favorite Restaurants',
            'Your favorite pancake spots',
            () {
              // Navigate to favorite restaurants
            },
          ),
          _buildMenuItem(
            Icons.notifications,
            'Notifications',
            'Manage your notifications',
            () {
              // Navigate to notifications
            },
          ),
          _buildMenuItem(
            Icons.help,
            'Help & Support',
            'Get help with the app',
            () {
              // Navigate to help
            },
          ),
          _buildMenuItem(
            Icons.info,
            'About',
            'App information and credits',
            () {
              _showAboutDialog();
            },
          ),
          _buildMenuItem(
            Icons.logout,
            'Sign Out',
            'Sign out of your account',
            () {
              _showSignOutDialog();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : AppColors.primaryCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.primaryBrown,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDestructive ? Colors.red : null,
              ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.primaryBrown.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Pancake Recipes'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version 1.0.0'),
              SizedBox(height: 8),
              Text('Discover amazing pancake recipes from top restaurants around the world.'),
              SizedBox(height: 8),
              Text('Made with Flutter and love for pancakes! 🥞'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Perform sign out
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Signed out successfully'),
                    backgroundColor: AppColors.primaryCyan,
                  ),
                );
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}