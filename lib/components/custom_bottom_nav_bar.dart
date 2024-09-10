import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppTheme.surfaceColor,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textSecondaryColor,
      items: items,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
    );
  }
}
