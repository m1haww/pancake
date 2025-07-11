import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../theme/app_theme.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'map_screen.dart';
import 'profile_page.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final bool showSearchBackButton;
  
  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.showSearchBackButton = false,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late final PageController _pageController;
  late final List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _pages = [
      const HomePage(),
      SearchPage(showBackButton: widget.showSearchBackButton),
      const MapScreen(),
      const ProfilePage(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        color: AppColors.primaryCyan,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CurvedNavigationBar(
              index: _currentIndex,
              height: 60,
              items: const [
                Icon(Icons.home, size: 30, color: Colors.white),
                Icon(Icons.search, size: 30, color: Colors.white),
                Icon(Icons.map, size: 30, color: Colors.white),
                Icon(Icons.person, size: 30, color: Colors.white),
              ],
              color: AppColors.primaryCyan,
              buttonBackgroundColor: AppColors.primaryBrown,
              backgroundColor: AppColors.background,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 300),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                
                // Use jump for non-adjacent tabs to avoid lag
                if ((index - _pageController.page!.round()).abs() > 1) {
                  _pageController.jumpToPage(index);
                } else {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
            Container(
              height: MediaQuery.of(context).padding.bottom,
              color: AppColors.primaryCyan,
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.primaryCyan,
    );
  }
}
