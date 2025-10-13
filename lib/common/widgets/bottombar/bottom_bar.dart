import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:flutter/material.dart';

class AnimatedBottomBar extends StatefulWidget {
  final Color? backgroundColor;
  final Function(int)? onItemTapped;
  final int selectedIndex;
  
  AnimatedBottomBar({
    Key? key,
    this.backgroundColor,
    this.onItemTapped,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  State<AnimatedBottomBar> createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? (context.isDarkMode ? Colors.grey[900] : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAnimatedItem('Home', Icons.home, 0),
          _buildAnimatedItem('Search', Icons.search, 1),
          _buildAnimatedItem('About', Icons.info_outline, 2),
          _buildAnimatedItem('Profile', Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(String label, IconData icon, int index) {
    bool isSelected = widget.selectedIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          if (widget.onItemTapped != null) {
            widget.onItemTapped!(index);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    top: BorderSide(color: AppColors.primary, width: 2),
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : (context.isDarkMode ? Colors.white60 : Colors.grey),
                size: isSelected ? 28 : 24,
              ),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}