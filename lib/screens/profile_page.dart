import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import 'edit_profile_screen.dart';
import 'favorites_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

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
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
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
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        _buildStatsSection(),
                        _buildMenuSection(),
                        _buildSignOutButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
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
      child: Row(
        children: [
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBrown,
              fontFamily: 'Gabarito',
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final appProvider = context.watch<AppProvider>();

    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryCyan, AppColors.secondaryCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: appProvider.profileImagePath != null
                  ? CircleAvatar(
                      radius: 55,
                      backgroundImage: FileImage(File(appProvider.profileImagePath!)),
                    )
                  : CircleAvatar(
                      radius: 55,
                      backgroundColor: AppColors.lightCream,
                      child: Icon(
                        CupertinoIcons.person_fill,
                        size: 60,
                        color: AppColors.primaryBrown,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            appProvider.userName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBrown,
              fontFamily: 'Gabarito',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            appProvider.userEmail,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.onBackground.withValues(alpha: 0.7),
              fontFamily: 'Gabarito',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBrown,
                  AppColors.primaryBrown.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBrown.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.pencil,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Gabarito',
                        ),
                      ),
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

  Widget _buildStatsSection() {
    final appProvider = context.watch<AppProvider>();
    final favoriteCount = appProvider.favoriteRecipes.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(20),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            'Favorites',
            favoriteCount.toString(),
            CupertinoIcons.heart_fill,
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.lightCream.withValues(alpha: 0.3),
          ),
          _buildStatItem('Reviews', '0', CupertinoIcons.star_fill),
          Container(
            width: 1,
            height: 50,
            color: AppColors.lightCream.withValues(alpha: 0.3),
          ),
          _buildStatItem('Photos', '0', CupertinoIcons.photo_fill),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryCyan, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBrown,
            fontFamily: 'Gabarito',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onBackground.withValues(alpha: 0.6),
            fontFamily: 'Gabarito',
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuGroup(
            title: 'Activity',
            items: [
              _MenuItemData(
                icon: CupertinoIcons.heart_fill,
                title: 'Favorite Recipes',
                subtitle: 'View your favorite recipes',
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMenuGroup(
            title: 'Settings',
            items: [
              _MenuItemData(
                icon: CupertinoIcons.doc_text_fill,
                title: 'Terms of Service',
                subtitle: 'View our terms',
                color: Colors.blue,
                onTap: () async {
                  const url = 'https://docs.google.com/document/d/1rrsdNLSnmE0yuFHXFaOY1-Y4mqtfDnPEhfx7tNrD3MM/edit?usp=sharing';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
              _MenuItemData(
                icon: CupertinoIcons.shield_fill,
                title: 'Privacy',
                subtitle: 'Privacy settings',
                color: Colors.green,
                onTap: () async {
                  const url = 'https://docs.google.com/document/d/1LzZYlpFwYGxh1LA0J8rCqYiweWgvAn1KCBL2vZvUluc/edit?usp=sharing';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
              _MenuItemData(
                icon: CupertinoIcons.question_circle_fill,
                title: 'Help & Support',
                subtitle: 'Get help with the app',
                color: Colors.orange,
                onTap: () {},
              ),
              _MenuItemData(
                icon: CupertinoIcons.info_circle_fill,
                title: 'About',
                subtitle: 'App information',
                color: AppColors.primaryBrown,
                onTap: () => _showAboutDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup({
    required String title,
    required List<_MenuItemData> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBrown,
              fontFamily: 'Gabarito',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCyan.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children:
                items.map((item) {
                  final isLast = items.last == item;
                  return Column(
                    children: [
                      _buildMenuItem(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle,
                        iconColor: item.color,
                        onTap: item.onTap,
                      ),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 1,
                            color: AppColors.lightCream.withValues(alpha: 0.3),
                          ),
                        ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                        fontFamily: 'Gabarito',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onBackground.withValues(alpha: 0.6),
                        fontFamily: 'Gabarito',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: AppColors.onBackground.withValues(alpha: 0.3),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Column(
      children: [
        SizedBox(height: 15),
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showDeleteDataDialog(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.trash, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'Delete Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gabarito',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(
              'Pancake Recipes',
              style: TextStyle(fontFamily: 'Gabarito'),
            ),
            content: Column(
              children: [
                const SizedBox(height: 8),
                Text('Version 1.0.0', style: TextStyle(fontFamily: 'Gabarito')),
                const SizedBox(height: 16),
                Text(
                  'Discover amazing pancake recipes from top restaurants around the world.',
                  style: TextStyle(fontFamily: 'Gabarito'),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: Text(
                    'Visit Website',
                    style: TextStyle(fontFamily: 'Gabarito'),
                  ),
                  onPressed: () async {
                    if (!mounted) return;
                    Navigator.pop(context);
                    const url = 'https://pancakerecipes.com';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    }
                  },
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('OK', style: TextStyle(fontFamily: 'Gabarito')),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _showDeleteDataDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(
              'Delete All Data',
              style: TextStyle(fontFamily: 'Gabarito'),
            ),
            content: Text(
              'This will permanently delete all your favorite recipes. This action cannot be undone.',
              style: TextStyle(fontFamily: 'Gabarito'),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Cancel', style: TextStyle(fontFamily: 'Gabarito')),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text(
                  'Delete All',
                  style: TextStyle(fontFamily: 'Gabarito'),
                ),
                onPressed: () {
                  // Clear all favorites
                  final appProvider = context.read<AppProvider>();
                  appProvider.clearAllFavorites();

                  Navigator.pop(context);

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('All data has been deleted'),
                      backgroundColor: AppColors.primaryCyan,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
